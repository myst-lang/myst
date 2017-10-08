require "./ast.cr"

module Myst
  class Parser < Lexer
    def self.for_file(source_file)
      new(File.open(source_file), source_file, File.expand_path(File.dirname(source_file)))
    end


    def initialize(source : IO, source_file : String? = nil, working_dir : String? = nil)
      super(source, source_file, working_dir)
      # A stack to track of variables defined locally in the current scope.
      @local_vars = [Set(String).new]
      read_token
    end



    ###
    # Movement
    #
    # Methods for moving through the source.
    ###

    # Skip through whitespace tokens, but only if the current token is already
    # a whitespace token.
    def skip_space
      skip_tokens(Token::Type.whitespace)
    end

    def skip_space_and_newlines
      skip_tokens(Token::Type.whitespace+[Token::Type::NEWLINE])
    end

    private def skip_tokens(allowed)
      while allowed.includes?(@current_token.type)
        read_token
      end
      @current_token
    end


    def accept(*types : Token::Type)
      if types.includes?(@current_token.type)
        token = @current_token
        read_token
        return token
      end
    end

    def expect(*types : Token::Type)
      accept(*types) || raise ParseError.new("Expected one of #{types.join(',')} but got #{@current_token.type}")
    end

    def expect_delimiter
      expect(Token::Type::SEMI, Token::Type::NEWLINE)
    end

    def expect_delimiter_or_eof
      expect(Token::Type::SEMI, Token::Type::NEWLINE, Token::Type::EOF)
    end



    ###
    # Parsers
    #
    # Methods for parsing source material into nodes. Each method will consume
    # exactly the number of tokens required to build its node.
    ###

    # Parse the entirety of the given source. Currently, this assumes valid
    # input and will only end when an EOF is encountered.
    def parse
      program = Expressions.new
      skip_space_and_newlines
      until accept(Token::Type::EOF)
        program.children << parse_expression
        expect_delimiter_or_eof
        skip_space_and_newlines
      end

      program
    end

    # A code block is a set of expressions contained by some other expression.
    # For example, the body of a method definition.
    def parse_code_block(*terminators)
      block = nil
      skip_space_and_newlines
      until terminators.includes?(current_token.type)
        block ||= Expressions.new
        block.children << parse_expression
        # In a code block, the last expression does not require a delimiter.
        # For example, `call{ a = 1; a + 2 } is valid, even though `a + 2` is
        # not followed by a delimiter. So, if the next significant token is a
        # terminator, stop expecting expressions/delimiters.
        skip_space
        break if terminators.includes?(current_token.type)
        expect_delimiter_or_eof
        skip_space_and_newlines
      end

      # If there were no expressions in the block, return a Nop instead.w
      block || Nop.new
    end

    def parse_expression
      case current_token.type
      when Token::Type::DEF
        parse_def
      when Token::Type::MODULE
        parse_module_def
      when Token::Type::INCLUDE
        parse_include
      when Token::Type::REQUIRE
        parse_require
      when Token::Type::RETURN, Token::Type::BREAK, Token::Type::NEXT
        parse_flow_control
      when Token::Type::WHEN, Token::Type::UNLESS
        parse_conditional
      when Token::Type::WHILE, Token::Type::UNTIL
        parse_loop
      else
        parse_logical_or
      end
    end

    def parse_def
      start = expect(Token::Type::DEF)
      skip_space
      name = expect(Token::Type::IDENT).value
      method_def = Def.new(name).at(start.location)
      push_var_scope

      # If the Def has parameters, they must be parenthesized. If the token
      # after the opening parenthesis is a closing one, then there are no
      # parameters.
      skip_space
      if accept(Token::Type::LPAREN)
        skip_space_and_newlines
        unless accept(Token::Type::RPAREN)
          allow_splat = true
          param_index = 0
          loop do
            skip_space_and_newlines
            next_param = parse_param(allow_splat)
            skip_space_and_newlines
            # Only one splat collector is allowed in a parameter list.
            if next_param.splat?
              allow_splat = false
              method_def.splat_index = param_index
            end

            # The block parameter must be the last parameter.
            if next_param.block?
              method_def.block_param = next_param
              if accept(Token::Type::RPAREN)
                break
              else
                raise ParseError.new("Block parameter must be the last parameter in a Def.")
              end
            end

            method_def.params << next_param
            param_index += 1

            # If there is no comma, this is the last parameter, and a closing
            # parenthesis should be expected.
            unless accept(Token::Type::COMMA)
              expect(Token::Type::RPAREN)
              break
            end
          end
        end
      end

      skip_space
      expect_delimiter
      skip_space_and_newlines

      if finish = accept(Token::Type::END)
        method_def.body = Nop.new
        pop_var_scope
        return method_def.at_end(finish.location)
      else
        method_def.body = parse_code_block(Token::Type::END)
        finish = expect(Token::Type::END)
        pop_var_scope
        return method_def.at_end(finish.location)
      end
    end

    def parse_param(allow_splat=true)
      param = Param.new

      case
      when start = accept(Token::Type::STAR)
        if allow_splat
          param.splat = true
          name = expect(Token::Type::IDENT)
          push_local_var(name.value)
          param.name = name.value
          return param.at(start.location).at_end(name.location)
        else
          raise ParseError.new("Multiple splat parameters are not allowed in a definition.")
        end
      when start = accept(Token::Type::AMPERSAND)
        param.block = true
        name = expect(Token::Type::IDENT)
        param.name = name.value
        # Named parameters should be treated as Vars (not Calls) within the Def
        # body. However, for a call syntax that is consistent with normal calls,
        # the block parameter is excluded from this.
        return param.at(start.location).at_end(name.location)
      when name = accept(Token::Type::IDENT)
        param.name = name.value
        push_local_var(name.value)
        param.at(name.location)
      else
        # If no other parameter syntax has matched, attempt to parse the
        # parameter as a pattern.
        param.pattern = to_pattern(parse_postfix)
        param.at(param.pattern)
        skip_space
        if accept(Token::Type::MATCH)
          skip_space
          name = expect(Token::Type::IDENT)
          push_local_var(name.value)
          param.name = name.value
          param.at_end(name.location)
        end
      end

      skip_space

      # A type restriction can follow any non-splat/block parameter.
      if accept(Token::Type::COLON)
        skip_space
        restriction = expect(Token::Type::CONST)
        param.restriction = Const.new(restriction.value).at(restriction.location)
        param.at_end(restriction.location)
      end

      return param
    end

    def parse_module_def
      start = expect(Token::Type::MODULE)
      skip_space
      name = expect(Token::Type::CONST).value
      skip_space
      expect_delimiter
      skip_space_and_newlines

      if finish = accept(Token::Type::END)
        return ModuleDef.new(name, Nop.new).at(start.location).at_end(finish.location)
      else
        push_var_scope
        body = parse_code_block(Token::Type::END)
        finish = expect(Token::Type::END)
        pop_var_scope
        return ModuleDef.new(name, body).at(start.location).at_end(finish.location)
      end
    end

    def parse_include
      start = expect(Token::Type::INCLUDE)
      skip_space
      if current_token.type == Token::Type::NEWLINE
        raise ParseError.new("expected value for include")
      end
      path = parse_expression
      return Include.new(path).at(start.location).at_end(path)
    end

    def parse_require
      start = expect(Token::Type::REQUIRE)
      skip_space
      if current_token.type == Token::Type::NEWLINE
        raise ParseError.new("expected value for require")
      end
      path = parse_expression
      return Require.new(path).at(start.location).at_end(path)
    end

    def parse_flow_control
      node =
        case
        when accept(Token::Type::RETURN)
          Return.new
        when accept(Token::Type::BREAK)
          Break.new
        when accept(Token::Type::NEXT)
          Next.new
        else
          raise ParseError.new("Expected one of return, break, or next, got #{current_token.inspect}")
        end

      skip_space

      unless current_token.type.delimiter?
        node.value = parse_expression
      end

      return node
    end

    def parse_conditional
      case
      when start = accept(Token::Type::WHEN)
        skip_space
        condition = parse_expression
        skip_space
        expect_delimiter
        skip_space_and_newlines
        body = parse_code_block(Token::Type::WHEN, Token::Type::UNLESS, Token::Type::ELSE, Token::Type::END)
        alternative = parse_conditional
        return When.new(condition, body, alternative).at(start.location).at_end(alternative)
      when start = accept(Token::Type::UNLESS)
        skip_space
        condition = parse_expression
        skip_space
        expect_delimiter
        skip_space_and_newlines
        body = parse_code_block(Token::Type::WHEN, Token::Type::UNLESS, Token::Type::ELSE, Token::Type::END)
        alternative = parse_conditional
        return Unless.new(condition, body, alternative).at(start.location).at_end(alternative)
      when start = accept(Token::Type::ELSE)
        skip_space
        expect_delimiter
        skip_space_and_newlines
        # An `else` does not have a condition, nor can it have an alternative,
        # so when encountered, simply parse and return the body.
        body = parse_code_block(Token::Type::END)
        expect(Token::Type::END)
        return body
      when finish = accept(Token::Type::END)
        return Nop.new.at_end(finish.location)
      else
        # This may be reached if a conditional is not properly closed.
        raise ParseError.new("Expected one of `when`, `unless`, or `else`, got #{current_token.inspect}")
      end
    end

    def parse_loop
      case
      when start = accept(Token::Type::WHILE)
        skip_space
        condition = parse_expression
        skip_space
        expect_delimiter
        skip_space_and_newlines

        body = parse_code_block(Token::Type::END)
        expect(Token::Type::END)
        return While.new(condition, body).at(start.location).at_end(body)
      when start = accept(Token::Type::UNTIL)
        skip_space
        condition = parse_expression
        skip_space
        expect_delimiter
        skip_space_and_newlines

        body = parse_code_block(Token::Type::END)
        expect(Token::Type::END)
        return Until.new(condition, body).at(start.location).at_end(body)
      else
        # This should never be reached.
        raise ParseError.new("Expected one of `while` or `until`, got #{current_token.inspect}")
      end
    end

    def parse_logical_or
      left = parse_logical_and
      skip_space

      if accept(Token::Type::OROR)
        skip_space_and_newlines
        right = parse_logical_or
        return Or.new(left, right).at(left).at_end(right)
      end

      return left
    end

    def parse_logical_and
      left = parse_equality
      skip_space

      if accept(Token::Type::ANDAND)
        skip_space_and_newlines
        right = parse_logical_and
        return And.new(left, right).at(left).at_end(right)
      end

      return left
    end

    def parse_equality
      left = parse_comparative
      skip_space

      if op = accept(Token::Type::EQUALEQUAL, Token::Type::NOTEQUAL)
        skip_space_and_newlines
        right = parse_equality
        return Call.new(left, op.value, [right] of Node).at(left).at_end(right)
      end

      return left
    end

    def parse_comparative
      left = parse_additive
      skip_space

      if op = accept(Token::Type::LESS, Token::Type::LESSEQUAL, Token::Type::GREATEREQUAL, Token::Type::GREATER)
        skip_space_and_newlines
        right = parse_comparative
        return Call.new(left, op.value, [right] of Node).at(left).at_end(right)
      end

      return left
    end

    # Arithmetic is left-associative. `1 - 1 - 1` _must_ be parsed as
    # `((1 - 1) - 1)` to follow mathematic precedence and give the right result
    # of `-2`, rather than `(1 - (1 - 1))`, which would yield `0`.
    def parse_additive(left=nil)
      left ||= parse_multiplicative
      skip_space

      if op = accept(Token::Type::PLUS, Token::Type::MINUS)
        skip_space_and_newlines
        right = parse_multiplicative
        call = Call.new(left, op.value, [right] of Node).at(left).at_end(right)
        return parse_additive(call)
      end

      return left
    end

    def parse_multiplicative(left=nil)
      left ||= parse_assign
      skip_space

      if op = accept(Token::Type::STAR, Token::Type::SLASH, Token::Type::MODULO)
        skip_space_and_newlines
        right = parse_assign
        call = Call.new(left, op.value, [right] of Node).at(left).at_end(right)
        return parse_multiplicative(call)
      end

      return left
    end

    def parse_assign
      target = parse_unary
      skip_space
      case
      when accept(Token::Type::EQUAL)
        skip_space_and_newlines
        value = parse_expression
        return SimpleAssign.new(to_lhs(target), value).at(target).at_end(value)
      when accept(Token::Type::MATCH)
        skip_space_and_newlines
        value = parse_expression
        return MatchAssign.new(to_pattern(target), value).at(target).at_end(value)
      when (op = current_token).type.op_assign?
        read_token
        skip_space_and_newlines
        value = parse_expression
        return OpAssign.new(to_lhs(target), op.value, value).at(target).at_end(value)
      end

      return target
    end

    def parse_unary
      case
      when start = accept(Token::Type::NOT)
        skip_space
        value = parse_unary
        return Not.new(value).at(start.location).at_end(value)
      when start = accept(Token::Type::MINUS)
        skip_space
        value = parse_unary
        return Negation.new(value).at(start.location).at_end(value)
      when start = accept(Token::Type::STAR)
        skip_space
        value = parse_unary
        return Splat.new(value).at(start.location).at_end(value)
      else
        return parse_postfix
      end
    end

    def parse_postfix(receiver=nil)
      receiver ||= parse_primary
      skip_space

      case
      when accept(Token::Type::POINT)
        skip_space_and_newlines
        return parse_postfix(parse_var_or_call(receiver))
      when accept(Token::Type::LBRACE)
        skip_space_and_newlines
        call = Call.new(receiver, "[]")

        loop do
          skip_space_and_newlines
          call.args << parse_expression
          skip_space_and_newlines

          # If there is no comma, this is the last argument, and a closing
          # parenthesis should be expected.
          unless accept(Token::Type::COMMA)
            finish = expect(Token::Type::RBRACE)
            call.at_end(finish.location)
            break
          end
        end

        return parse_postfix(call)
      else
        return receiver
      end
    end

    def parse_primary
      case current_token.type
      when Token::Type::LPAREN
        accept(Token::Type::LPAREN)
        skip_space_and_newlines
        expr = parse_expression
        skip_space_and_newlines
        expect(Token::Type::RPAREN)
        skip_space_and_newlines
        return expr
      when Token::Type::SELF
        token = current_token
        read_token
        return Self.new.at(token.location)
      when Token::Type::CONST
        token = current_token
        read_token
        return Const.new(token.value)
      when Token::Type::LESS
        parse_value_interpolation
      when Token::Type::IDENT
        parse_var_or_call
      else
        parse_literal
      end
    end

    def parse_value_interpolation
      start = expect(Token::Type::LESS)
      skip_space_and_newlines
      value = parse_unary
      skip_space_and_newlines
      finish = expect(Token::Type::GREATER)
      return ValueInterpolation.new(value).at(start.location).at_end(finish.location)
    end

    def parse_var_or_call(receiver=nil)
      start = expect(Token::Type::IDENT, Token::Type::CONST)
      name  = start.value

      if receiver.nil?
        if name.starts_with?('_')
          return Underscore.new(name).at(start.location)
        end

        if is_local_var?(name)
          return Var.new(name).at(start.location)
        end
      end

      call = Call.new(receiver, name).at(start.location)
      skip_space
      if accept(Token::Type::LPAREN)
        skip_space_and_newlines

        if finish = accept(Token::Type::RPAREN)
          call.at_end(finish.location)
        else
          loop do
            skip_space_and_newlines
            call.args << parse_expression
            skip_space_and_newlines

            # If there is no comma, this is the last argument, and a closing
            # parenthesis should be expected.
            unless accept(Token::Type::COMMA)
              finish = expect(Token::Type::RPAREN)
              call.at_end(finish.location)
              break
            end
          end
        end
      end

      skip_space
      if call.block = parse_optional_block
        return call.at_end(call.block)
      end

      return call
    end

    def parse_optional_block
      block = Block.new
      end_token =
        case
        when start = accept(Token::Type::LCURLY)
          block.at(start.location)
          Token::Type::RCURLY
        when start = accept(Token::Type::DO)
          block.at(start.location)
          Token::Type::END
        else
          # If a block token is not present, there is no block present, so the
          # attempt to parse one can stop.
          return
        end

      skip_space
      if accept(Token::Type::PIPE)
        skip_space_and_newlines
        unless accept(Token::Type::PIPE)
          allow_splat = true
          param_index = 0
          loop do
            skip_space_and_newlines
            next_param = parse_param(allow_splat)
            skip_space_and_newlines
            # Only one splat collector is allowed in a parameter list.
            if next_param.splat?
              allow_splat = false
              block.splat_index = param_index
            end

            # The block parameter must be the last parameter.
            if next_param.block?
              block.block_param = next_param
              if accept(Token::Type::PIPE)
                break
              else
                raise ParseError.new("Block parameter must be the last parameter in a Def.")
              end
            end

            block.params << next_param
            param_index += 1

            # If there is no comma, this is the last parameter, and a closing
            # parenthesis should be expected.
            unless accept(Token::Type::COMMA)
              expect(Token::Type::PIPE)
              break
            end
          end
        end
      end

      expect_delimiter if end_token == Token::Type::END
      skip_space_and_newlines
      if finish = accept(end_token)
        return block.at_end(finish.location)
      else
        block.body = parse_code_block(end_token)
        finish = expect(end_token)
        return block.at_end(finish.location)
      end
    end

    def parse_literal
      case (token = current_token).type
      when Token::Type::NIL
        read_token
        NilLiteral.new.at(token.location)
      when Token::Type::TRUE
        read_token
        BooleanLiteral.new(true).at(token.location)
      when Token::Type::FALSE
        read_token
        BooleanLiteral.new(false).at(token.location)
      when Token::Type::INTEGER
        read_token
        IntegerLiteral.new(token.value).at(token.location)
      when Token::Type::FLOAT
        read_token
        FloatLiteral.new(token.value).at(token.location)
      when Token::Type::STRING
        read_token
        StringLiteral.new(token.value).at(token.location)
      when Token::Type::SYMBOL
        read_token
        SymbolLiteral.new(token.value).at(token.location)
      when Token::Type::LBRACE
        parse_list_literal
      when Token::Type::LCURLY
        parse_map_literal
      else
        raise ParseError.new("Expected a literal value. Got #{current_token.inspect} instead")
      end
    end


    def parse_list_literal
      start = expect(Token::Type::LBRACE)
      list = ListLiteral.new.at(start.location)

      skip_space_and_newlines
      # If the next token is a closing brace, create an empty list
      if finish = accept(Token::Type::RBRACE)
        return list.at_end(finish.location)
      end

      # Otherwise, there must be at least one expression to be parsed.
      loop do
        list.elements << parse_expression
        skip_space_and_newlines
        if accept(Token::Type::COMMA)
          skip_space_and_newlines
          next
        end
        if finish = accept(Token::Type::RBRACE)
          return list.at_end(finish.location)
        end
      end
    end

    def parse_map_literal
      start = expect(Token::Type::LCURLY)
      map = MapLiteral.new.at(start.location)

      skip_space_and_newlines
      if finish = accept(Token::Type::RCURLY)
        return map.at_end(finish.location)
      end

      loop do
        key = parse_map_key
        skip_space_and_newlines
        value = parse_expression
        map.entries << MapLiteral::Entry.new(key: key, value: value)
        skip_space_and_newlines
        if accept(Token::Type::COMMA)
          skip_space_and_newlines
          next
        end
        if finish = accept(Token::Type::RCURLY)
          return map.at_end(finish.location)
        end
      end
    end

    def parse_map_key
      key =
        case current_token.type
        when Token::Type::IDENT
          name = expect(Token::Type::IDENT)
          SymbolLiteral.new(name.value).at(name.location)
        when Token::Type::LESS
          parse_value_interpolation
        else
          raise ParseError.new("#{current_token} is not a valid map key")
        end
      # Keys must be _immediately_ followed by a colon, with no spaces between
      # the end of the key and the colon. This applies to both symbols and
      # value interpolations.
      expect(Token::Type::COLON)
      return key
    end



    ###
    # Conversions
    #
    # Methods to convert node types based on some context.
    ###

    # Convert the given node to one that is suitable for the left-hand-side of
    # an *Assign node.
    private def to_lhs(node)
      case node
      when Var
        push_local_var(node.name)
        return node
      when Underscore
        push_local_var(node.name)
        return node
      when Const
        return node
      when Call
        # If no explicit receiver was set on the Call, consider it a Var.
        if node.receiver? || node.block? || !node.args.empty?
          return node
        else
          push_local_var(node.name)
          return Var.new(node.name).at(node)
        end
      when Literal
        raise ParseError.new("Cannot assign to literal value.")
      else
        raise ParseError.new("Invalid value for LHS of Assign: #{node}")
      end
    end

    # Recursively scan the given node, transforming it's elements to be
    # suitable for use as a Pattern.
    private def to_pattern(node)
      case node
      when Var
        push_local_var(node.name)
        return node
      when Underscore
        push_local_var(node.name)
        return node
      when Const
        return node
      when Call
        # Only bare calls can be used as bindings in a pattern.
        if node.receiver? || node.block? || !node.args.empty?
          raise "Calls are not allowed in patterns."
        else
          push_local_var(node.name)
          return Var.new(node.name).at(node)
        end
      when ListLiteral
        node.elements = node.elements.map{ |e| to_pattern(e).as(Node) }
      when MapLiteral
        node.entries = node.entries.map{ |e| MapLiteral::Entry.new(e.key, to_pattern(e.value).as(Node)) }
      when Splat
        node.value = to_pattern(node.value)
      end

      return node
    end



    ###
    # Utilities
    #
    # Utility methods for managing the state of the parser.
    ###

    def push_var_scope(scope=Set(String).new)
      @local_vars.push(scope)
    end

    def pop_var_scope
      @local_vars.pop
    end

    def push_local_var(name : String)
      @local_vars.last.add(name)
    end

    def is_local_var?(name : String)
      @local_vars.last.includes?(name)
    end
  end
end
