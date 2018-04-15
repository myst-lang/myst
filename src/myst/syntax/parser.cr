require "./ast.cr"

module Myst
  class Parser < Lexer
    def self.for_file(source_file)
      new(File.open(source_file), source_file)
    end

    def self.for_content(content)
      new(IO::Memory.new(content), "eval_input")
    end

    def initialize(source : IO, source_file : String)
      super(source, source_file)
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
      skip_tokens(Token::Type.whitespace + [Token::Type::NEWLINE])
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
      accept(*types) || raise ParseError.new(current_location, "Expected one of #{types.join(',')} but got #{@current_token.type}")
    end

    def accept_delimiter
      accept(Token::Type::SEMI, Token::Type::NEWLINE)
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
        # Doc comments are not (can not be) delimited by newlines since they
        # do not have an explicit closing token, so skip the expectation of a
        # delimiter if the previous expression was a doc comment.
        unless program.children.last.is_a?(DocComment)
          expect_delimiter_or_eof
        end
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
        skip_space
        # In a code block, the last expression does not require a delimiter.
        # For example, `call{ a = 1; a + 2 } is valid, even though `a + 2` is
        # not followed by a delimiter. So, if the next significant token is a
        # terminator, stop expecting expressions/delimiters.
        break if terminators.includes?(current_token.type)
        # Additionally, doc comments are not (can not be) delimited by newlines
        # since they do not have an explicit closing token, so skip that
        # expectation if the previous expression was a doc comment.
        unless block.children.last.is_a?(DocComment)
          expect_delimiter_or_eof
        end
        skip_space_and_newlines
      end

      # If there were no expressions in the block, return a Nop instead.
      block || Nop.new
    end

    def parse_expression
      case current_token.type
      when Token::Type::DEF, Token::Type::DEFSTATIC
        parse_def
      when Token::Type::DEFMODULE
        parse_module_def
      when Token::Type::DEFTYPE
        parse_type_def
      when Token::Type::FN
        parse_anonymous_function
      when Token::Type::MATCH
        parse_match
      when Token::Type::INCLUDE
        parse_include
      when Token::Type::EXTEND
        parse_extend
      when Token::Type::REQUIRE
        parse_require
      when Token::Type::WHEN, Token::Type::UNLESS
        parse_conditional
      when Token::Type::WHILE, Token::Type::UNTIL
        parse_loop
      when Token::Type::AMPERSAND
        parse_function_capture
      when Token::Type::MAGIC_FILE, Token::Type::MAGIC_LINE, Token::Type::MAGIC_DIR
        parse_magic_constant
      when Token::Type::DOC_START
        parse_doc_comment
      else
        parse_logical_or
      end
    end

    def parse_def
      start = expect(Token::Type::DEF, Token::Type::DEFSTATIC)
      static = (start.type == Token::Type::DEFSTATIC)
      skip_space
      name = parse_def_name
      if is_local_var?(name)
        raise ParseError.new(current_location, "Function name `#{name}` collides with existing local variable. Clauses defined with `def` cannot be applied to variables.\n")
      end

      method_def = Def.new(name, static: static).at(start.location)
      push_var_scope

      skip_space
      parse_param_list(into: method_def)

      skip_space
      expect_delimiter
      skip_space_and_newlines

      if finish = accept(Token::Type::END)
        method_def.body = Nop.new
        pop_var_scope
        return method_def.at_end(finish.location)
      else
        method_def.body = parse_exception_handler
        finish = expect(Token::Type::END)
        pop_var_scope
        return method_def.at_end(finish.location)
      end
    end

    def parse_def_name
      case (token = current_token).type
      when Token::Type::IDENT
        expect(Token::Type::IDENT)
        name = token.value
        # If the name is unmodified, it can be followed by an `=` to create an
        # assignment method.
        if !modified_ident?(name) && accept(Token::Type::EQUAL)
          name += "="
        end
        name
      when Token::Type::LBRACE
        # An access overload is written as `[]`, so an RBRACE must also be
        # given for the method name to be valid.
        expect(Token::Type::LBRACE)
        expect(Token::Type::RBRACE)
        # An `=` can also be given to specify access assignment
        if accept(Token::Type::EQUAL)
          return "[]="
        else
          return "[]"
        end
      when .overloadable_operator?
        read_token
        # Any overloadable operator is also allowed
        token.value
      else
        raise ParseError.new(current_location, "Invalid name for def: #{token.value}")
      end
    end

    # If a Def has parameters, they must be parenthesized. If the token after
    # the opening parenthesis is a closing one, then there are no parameters.
    def parse_param_list(into target : Def, require_parens = false)
      if (require_parens ? expect(Token::Type::LPAREN) : accept(Token::Type::LPAREN))
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
              target.splat_index = param_index
            end

            # The block parameter must be the last parameter.
            if next_param.block?
              target.block_param = next_param
              if accept(Token::Type::RPAREN)
                break
              else
                raise ParseError.new(current_location, "Block parameter must be the last parameter in a Def.")
              end
            end

            target.params << next_param
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
    end

    def parse_param(allow_splat = true)
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
          raise ParseError.new(current_location, "Multiple splat parameters are not allowed in a definition.")
        end
      when start = accept(Token::Type::AMPERSAND)
        param.block = true
        name = expect(Token::Type::IDENT)
        param.name = name.value
        push_local_var(name.value)
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
        if accept(Token::Type::MATCH_OP)
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

    def parse_anonymous_function
      start = expect(Token::Type::FN)
      skip_space_and_newlines
      if accept(Token::Type::END)
        raise ParseError.new(current_location, "No clause given for anonymous function; at least one is required.")
      end

      func = AnonymousFunction.new.at(start.location)
      loop do
        skip_space_and_newlines

        # Anonymous functions _must_ contain at least one clause definition, so
        # a stab is always expected.
        clause_start = expect(Token::Type::STAB)
        skip_space

        push_var_scope
        block = Block.new
        parse_param_list(into: block, require_parens: true)
        skip_space

        closing_brace =
          case
          when accept(Token::Type::DO)
            skip_space_and_newlines
            block.body = parse_exception_handler

            Token::Type::END
          when accept(Token::Type::LCURLY)
            skip_space_and_newlines
            block.body = parse_code_block(Token::Type::RCURLY)

            Token::Type::RCURLY
          else
            raise ParseError.new(current_location, "Expected `{` or `do` to start a block body. Got #{current_token.type}.")
          end

        skip_space_and_newlines
        clause_finish = expect(closing_brace)

        skip_space_and_newlines
        pop_var_scope
        func.clauses << block.at(clause_start.location).at_end(clause_finish.location)

        # Anonymous functions are closed by an `end` keyword. Once that is
        # encountered, the loop for clauses can end.
        if finish = accept(Token::Type::END)
          func.at_end(finish.location)
          break
        end
      end

      return func
    end

    def parse_match
      start = expect(Token::Type::MATCH)

      match = Match.new.at(start.location)
      loop do
        skip_space
        match.arguments << parse_expression
        skip_space
        # Since there are no parentheses around `match` arguments, only an
        # expression delimiter indicates the end of the argument list.
        break if accept_delimiter
        # Otherwise, the next expression
        expect(Token::Type::COMMA)
      end

      skip_space_and_newlines
      if accept(Token::Type::END)
        raise ParseError.new(current_location, "No clause given for match; at least one is required.")
      end

      loop do
        skip_space_and_newlines

        # Anonymous functions _must_ contain at least one clause definition, so
        # a stab is always expected.
        clause_start = expect(Token::Type::STAB)
        skip_space

        push_var_scope
        block = Block.new
        parse_param_list(into: block, require_parens: true)
        skip_space

        closing_brace =
          case
          when accept(Token::Type::DO)
            skip_space_and_newlines
            block.body = parse_exception_handler

            Token::Type::END
          when accept(Token::Type::LCURLY)
            skip_space_and_newlines
            block.body = parse_code_block(Token::Type::RCURLY)

            Token::Type::RCURLY
          else
            raise ParseError.new(current_location, "Expected `{` or `do` to start a block body. Got #{current_token.type}.")
          end

        skip_space_and_newlines
        clause_finish = expect(closing_brace)

        skip_space_and_newlines
        pop_var_scope
        match.clauses << block.at(clause_start.location).at_end(clause_finish.location)

        # Anonymous functions are closed by an `end` keyword. Once that is
        # encountered, the loop for clauses can end.
        if finish = accept(Token::Type::END)
          match.at_end(finish.location)
          break
        end
      end

      return match
    end

    def parse_module_def
      start = expect(Token::Type::DEFMODULE)
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

    def parse_type_def
      start = expect(Token::Type::DEFTYPE)
      skip_space
      name = expect(Token::Type::CONST).value
      skip_space
      # Type definitions can optionally provide a supertype to inherit from.
      supertype =
        if accept(Token::Type::COLON)
          skip_space
          parse_type_path
        end
      skip_space
      expect_delimiter
      skip_space_and_newlines

      if finish = accept(Token::Type::END)
        return TypeDef.new(name, Nop.new, supertype: supertype).at(start.location).at_end(finish.location)
      else
        push_var_scope
        body = parse_code_block(Token::Type::END)
        finish = expect(Token::Type::END)
        pop_var_scope
        return TypeDef.new(name, body, supertype: supertype).at(start.location).at_end(finish.location)
      end
    end

    def parse_type_path
      case current_token.type
      when Token::Type::CONST
        token = current_token
        read_token
        path = Const.new(token.value).at(token.location)
        while accept(Token::Type::POINT)
          next_path_part = expect(Token::Type::CONST)
          path = Call.new(path, next_path_part.value).at(path.location).at_end(next_path_part.location)
        end

        path
      when Token::Type::LESS
        parse_value_interpolation
      else
        raise ParseError.new(current_location, "Expected supertype after colon in type definition")
      end
    end

    def parse_include
      start = expect(Token::Type::INCLUDE)
      skip_space
      if current_token.type == Token::Type::NEWLINE
        raise ParseError.new(current_location, "expected value for include")
      end
      path = parse_expression
      return Include.new(path).at(start.location).at_end(path)
    end

    def parse_extend
      start = expect(Token::Type::EXTEND)
      skip_space
      if current_token.type == Token::Type::NEWLINE
        raise ParseError.new(current_location, "expected value for extend")
      end
      path = parse_expression
      return Extend.new(path).at(start.location).at_end(path)
    end

    def parse_require
      start = expect(Token::Type::REQUIRE)
      skip_space
      if current_token.type == Token::Type::NEWLINE
        raise ParseError.new(current_location, "expected value for require")
      end
      path = parse_expression
      return Require.new(path).at(start.location).at_end(path)
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
        raise ParseError.new(current_location, "Expected one of `when`, `unless`, or `else`, got #{current_token.inspect}")
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
        raise ParseError.new(current_location, "Expected one of `while` or `until`, got #{current_token.inspect}")
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
      left = parse_flow_control
      skip_space

      if accept(Token::Type::ANDAND)
        skip_space_and_newlines
        right = parse_logical_and
        return And.new(left, right).at(left).at_end(right)
      end

      return left
    end

    def parse_flow_control
      node =
        case
        when token = accept(Token::Type::RETURN)
          Return.new.at(token.location)
        when token = accept(Token::Type::BREAK)
          Break.new.at(token.location)
        when token = accept(Token::Type::NEXT)
          Next.new.at(token.location)
        when token = accept(Token::Type::RAISE)
          Raise.new.at(token.location)
        else
          return parse_equality
        end

      skip_space

      unless current_token.type.delimiter?
        node.value = parse_expression
      end

      if node.is_a?(Raise) && !node.value?
        raise ParseError.new(current_location, "`raise` must be given a value.")
      end

      return node
    end

    def parse_equality
      left = parse_comparative
      skip_space

      if op = accept(Token::Type::EQUALEQUAL, Token::Type::NOTEQUAL)
        skip_space_and_newlines
        right = parse_equality
        return Call.new(left, op.value, [right] of Node, infix: true).at(left).at_end(right)
      end

      return left
    end

    def parse_comparative
      left = parse_additive
      skip_space

      if op = accept(Token::Type::LESS, Token::Type::LESSEQUAL, Token::Type::GREATEREQUAL, Token::Type::GREATER)
        skip_space_and_newlines
        right = parse_comparative
        return Call.new(left, op.value, [right] of Node, infix: true).at(left).at_end(right)
      end

      return left
    end

    # Arithmetic is left-associative. `1 - 1 - 1` _must_ be parsed as
    # `((1 - 1) - 1)` to follow mathematic precedence and give the right result
    # of `-2`, rather than `(1 - (1 - 1))`, which would yield `0`.
    def parse_additive(left = nil)
      left ||= parse_multiplicative
      skip_space

      if op = accept(Token::Type::PLUS, Token::Type::MINUS)
        skip_space_and_newlines
        right = parse_multiplicative
        call = Call.new(left, op.value, [right] of Node, infix: true).at(left).at_end(right)
        return parse_additive(call)
      end

      return left
    end

    def parse_multiplicative(left = nil)
      left ||= parse_assign
      skip_space

      if op = accept(Token::Type::STAR, Token::Type::SLASH, Token::Type::MODULO)
        skip_space_and_newlines
        right = parse_assign
        call = Call.new(left, op.value, [right] of Node, infix: true).at(left).at_end(right)
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
        case target = to_lhs(target)
        when Call
          # Call targets get re-written from a SimpleAssign to a method call
          # with a `=` appended to the given name. For example, the assignment
          # `a.b = c` would be re-written as a Call on `a` to the method `b=`
          # with an argument of `c`.
          #
          # This also applies to access notation calls. They are rewritten from
          # `a[b] = c` to a Call on `a` to the method `[]=` with the arguments
          # `b, c`, this could also be written as `a.[]=(b, c).
          #
          # `to_lhs` should guarantee that `target.name` is a String, but
          # Crystal has no way of knowing that, so the long-form assignment is
          # necessary.
          target.name = target.name.as(String) + "="
          target.args << value
          return target
        else
          return SimpleAssign.new(target, value).at(target).at_end(value)
        end
      when accept(Token::Type::MATCH_OP)
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

    def parse_postfix(receiver = nil)
      receiver ||= parse_primary
      skip_space

      case
      when accept(Token::Type::POINT)
        skip_space_and_newlines
        return parse_postfix(parse_var_or_call(receiver))
      when start = accept(Token::Type::LBRACE)
        skip_space_and_newlines
        call = Call.new(receiver, "[]").at(start.location)

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

      # While `parse_var_or_call` can distinguish Calls for string identifiers,
      # its isolated scope (just the current token) means it cannot be
      # responsible for parsing Calls from arbitrary expressions. However,
      # since these are just postfix expressions, those can be handled here.
      when start = accept(Token::Type::LPAREN)
        skip_space_and_newlines
        call = Call.new(nil, receiver).at(start.location)

        if finish = accept(Token::Type::RPAREN)
          call.at_end(finish.location)
        else
          loop do
            skip_space_and_newlines
            case current_token.type
            when Token::Type::AMPERSAND
              call.block = parse_function_capture
            else
              call.args << parse_expression
            end
            skip_space_and_newlines

            if accept(Token::Type::COMMA)
              # Function captures must be given as the last argument in a Call.
              # If a comma was encountered after the block has been set, then
              # the capture was not the last argument, and thus invalid.
              if call.block?
                raise ParseError.new(current_location, "Function captures as block arguments must be given as the last argument for a Call.")
              end
            else
              # If there is no comma, this is the last argument, and a closing
              # parenthesis should be expected.
              finish = expect(Token::Type::RPAREN)
              call.at_end(finish.location)
              break
            end
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
        skip_space
        return expr
      when Token::Type::SELF
        token = current_token
        read_token
        return Self.new.at(token.location)
      when Token::Type::CONST
        token = current_token
        read_token
        return Const.new(token.value).at(token.location)
      when Token::Type::LESS
        parse_value_interpolation
      when Token::Type::IDENT
        parse_var_or_call
      when Token::Type::IVAR
        token = current_token
        read_token
        return IVar.new(token.value).at(token.location)
      when Token::Type::MODULO
        parse_instantiation
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

    def parse_var_or_call(receiver = nil)
      start = expect(Token::Type::IDENT, Token::Type::CONST)
      name = start.value

      skip_space
      if receiver.nil? && current_token.type != Token::Type::LPAREN
        if name.starts_with?('_')
          return Underscore.new(name).at(start.location)
        end

        if is_local_var?(name)
          return Var.new(name).at(start.location)
        end
      end

      call = Call.new(receiver, name).at(start.location)
      if accept(Token::Type::LPAREN)
        skip_space_and_newlines

        if finish = accept(Token::Type::RPAREN)
          call.at_end(finish.location)
        else
          loop do
            skip_space_and_newlines
            case current_token.type
            when Token::Type::AMPERSAND
              call.block = parse_function_capture
            else
              call.args << parse_expression
            end
            skip_space_and_newlines

            if accept(Token::Type::COMMA)
              # Function captures must be given as the last argument in a Call.
              # If a comma was encountered after the block has been set, then
              # the capture was not the last argument, and thus invalid.
              if call.block?
                raise ParseError.new(current_location, "Function captures as block arguments must be given as the last argument for a Call.")
              end
            else
              # If there is no comma, this is the last argument, and a closing
              # parenthesis should be expected.
              finish = expect(Token::Type::RPAREN)
              call.at_end(finish.location)
              break
            end
          end
        end
      end

      skip_space
      if inline_block = parse_optional_block
        # If a block argument was already specified by a function capture,
        # inline blocks are not allowed. Checking this after parsing the
        # optional block allows for a more helpful error message.
        if call.block?
          raise ParseError.new(current_location, "A block argument has already been given by a captured function. Defining an extra inline block is not allowed.")
        end

        call.block = inline_block
        return call.at_end(call.block)
      end

      return call
    end

    def parse_optional_block
      block = Block.new
      end_token =
        case
        when start = accept(Token::Type::LCURLY)
          block.style = :brace
          block.at(start.location)
          Token::Type::RCURLY
        when start = accept(Token::Type::DO)
          block.style = :doend
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
                raise ParseError.new(current_location, "Block parameter must be the last parameter in a Def.")
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
        if end_token == Token::Type::END
          block.body = parse_exception_handler
        else
          block.body = parse_code_block(end_token)
        end
        finish = expect(end_token)
        return block.at_end(finish.location)
      end
    end

    def parse_exception_handler
      body = parse_code_block(Token::Type::RESCUE, Token::Type::ENSURE, Token::Type::END)
      handler = ExceptionHandler.new(body)

      handler_needed = false
      loop do
        case current_token.type
        when Token::Type::RESCUE
          handler_needed = true
          if handler.ensure?
            # `ensure` _must_ be the last clause of an ExceptionHandler. A
            # `rescue` after the `ensure` is invalid.
            raise ParseError.new(current_location, "ensure must be the last clause of an exception handler.")
          end

          rescue_start = expect(Token::Type::RESCUE)
          skip_space
          # If any other token appears before a delimiter, it must be part of
          # a parameter for the Rescue.
          unless accept_delimiter
            param = parse_param
          end
          skip_space_and_newlines
          rescue_body = parse_code_block(Token::Type::RESCUE, Token::Type::ENSURE, Token::Type::END)
          handler.rescues << Rescue.new(rescue_body, param).at(rescue_start.location).at_end(rescue_body)
        when Token::Type::ENSURE
          handler_needed = true

          ensure_start = expect(Token::Type::ENSURE)
          skip_space
          expect_delimiter
          skip_space_and_newlines

          if handler.ensure?
            # Only 1 ensure is allowed in an ExceptionHandler.
            raise ParseError.new(current_location, "only one ensure clause may be provided for a block.")
          else
            handler.ensure = parse_code_block(Token::Type::RESCUE, Token::Type::ENSURE, Token::Type::END)
          end
        when Token::Type::END
          break
        else
          raise ParseError.new(current_location, "Expected one of `rescue`, `ensure`, or `else`")
        end
      end

      # If no handler was created, just return the given body as-is.
      return handler_needed ? handler : body
    end

    def parse_instantiation
      start = expect(Token::Type::MODULO)
      type = parse_type_path

      inst = Instantiation.new(type).at(start.location)
      skip_space
      expect(Token::Type::LCURLY)
      skip_space_and_newlines

      if finish = accept(Token::Type::RCURLY)
        inst.at_end(finish.location)
      else
        loop do
          skip_space_and_newlines
          case current_token.type
          when Token::Type::AMPERSAND
            inst.block = parse_function_capture
          else
            inst.args << parse_expression
          end
          skip_space_and_newlines

          # If there is no comma, this is the last argument, and a closing
          # parenthesis should be expected.
          unless accept(Token::Type::COMMA)
            finish = expect(Token::Type::RCURLY)
            inst.at_end(finish.location)
            break
          end
        end
      end

      skip_space
      if inline_block = parse_optional_block
        # If a block argument was already specified by a function capture,
        # inline blocks are not allowed. Checking this after parsing the
        # optional block allows for a more helpful error message.
        if inst.block?
          raise ParseError.new(current_location, "A block argument has already been given by a captured function. Defining an extra inline block is not allowed.")
        end

        inst.block = inline_block
        return inst.at_end(inst.block)
      end

      return inst
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
      when Token::Type::STRING, Token::Type::INTERP_START
        parse_string_literal
      when Token::Type::SYMBOL
        read_token
        SymbolLiteral.new(token.value).at(token.location)
      when Token::Type::LBRACE
        parse_list_literal
      when Token::Type::LCURLY
        parse_map_literal
      else
        raise ParseError.new(current_location, "Expected a literal value. Got #{current_token.inspect} instead")
      end
    end

    record StringPiece,
      node : Node,
      type : Symbol

    def parse_string_literal
      pieces = [] of StringPiece
      loop do
        case (token = current_token).type
        when Token::Type::STRING
          expect(Token::Type::STRING)
          # Only add the string piece if it contains one or more characters.
          # Strings of zero width are not valuable.
          if token.value.size > 0
            pieces.push(StringPiece.new(
              node: StringLiteral.new(token.value).at(token.location),
              type: :string
            ))
          end
        when Token::Type::INTERP_START
          expect(Token::Type::INTERP_START)
          # If the interpolation contains no expression, it can be ignored.
          skip_space_and_newlines
          if accept(Token::Type::INTERP_END)
            next
          else
            interpolated_expression = parse_expression
            skip_space_and_newlines
            expect(Token::Type::INTERP_END)
            pieces.push(StringPiece.new(
              node: interpolated_expression,
              type: :interpolation
            ))
          end
        else
          break
        end
      end

      case
      when pieces.size == 0
        # If there are no pieces to the string literal after parsing, infer a
        # blank string.
        return StringLiteral.new("").at(current_location)
      when pieces.size == 1 && pieces.first.type == :string
        return pieces.first.node
      else
        piece_nodes = pieces.map(&.node)
        first_node = piece_nodes.first
        last_node = piece_nodes.last
        return InterpolatedStringLiteral.new(piece_nodes).at(first_node).at_end(last_node)
      end
    end

    def parse_magic_constant
      token = expect(Token::Type::MAGIC_FILE, Token::Type::MAGIC_LINE, Token::Type::MAGIC_DIR)
      skip_space
      case token.type
      when Token::Type::MAGIC_FILE
        MagicConst.new(:"__FILE__").at(token.location)
      when Token::Type::MAGIC_LINE
        MagicConst.new(:"__LINE__").at(token.location)
      else
        MagicConst.new(:"__DIR__").at(token.location)
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
          raise ParseError.new(current_location, "#{current_token} is not a valid map key")
        end
      # Keys must be _immediately_ followed by a colon, with no spaces between
      # the end of the key and the colon. This applies to both symbols and
      # value interpolations.
      expect(Token::Type::COLON)
      return key
    end

    def parse_function_capture
      start = expect(Token::Type::AMPERSAND)
      skip_space

      value = parse_expression
      return FunctionCapture.new(value).at(start.location).at_end(value)
    end

    def parse_doc_comment
      start = expect(Token::Type::DOC_START)
      skip_space
      header = start.value.strip
      skip_space

      last_content_token = start
      content = String.build do |str|
        loop do
          skip_space_and_newlines
          if token = accept(Token::Type::DOC_CONTENT)
            # Remove trailing whitespace from the line (leading whitespace is)
            # preserved.
            str << token.value.rstrip
            # removing the whitespace above will also trim the last newline
            # character. To simplify the auto-formatting done later, this
            # newline is re-added to separate each DOC_CONTENT line.
            str << "\n"
            last_content_token = token
          else
            break
          end
        end
      end

      content =
        # Apply the formatting rules for doc comments to the content:
        content.
          # - whitespace at the beginning and end of the comment are removed.
          strip.
          # - strip trailing whitespace from every line
          gsub(/\h+\n/, '\n').
          # - empty lines have all interior whitspace stripped.
          gsub(/\n\s*\n/, "\n\n").
          # - single newlines are converted to single spaces.
          gsub(/(?<!\n)\n(?!\n)/, ' ').
          # - double newlines are converted to single newlines.
          gsub(/\n\n/, '\n')

      # Doc comments expect to be followed by an expression. That expression is
      # what the documentation will be attached to.
      target = parse_expression
      return DocComment.new(header, content, target).at(start.location).at_end(last_content_token.location)
    end



    ###
    # Conversions
    #
    # Methods to convert node types based on some context.
    ###

    # Convert the given node to one that is suitable for the left-hand side of
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
      when IVar
        return node
      when Call
        name = node.name
        # Dynamic call expressions cannot be used on the left-hand side.
        # Method names with modifiers (e.g., `foo?`) are not allowed on the
        # left-hand-side of an assignment
        if name.is_a?(Node)
          raise ParseError.new(current_location, "Dynamic call expressions cannot be used on the left-hand side.")
        end

        if modified_ident?(name)
          raise ParseError.new(current_location, "Method names with modifiers (`?` and `!`) are not allowed as targets for assignment")
        end
        # If no explicit receiver was set on the Call, consider it a Var.
        if node.receiver? || node.block? || !node.args.empty?
          return node
        else
          push_local_var(name)
          return Var.new(name).at(node)
        end
      when Literal
        raise ParseError.new(current_location, "Cannot assign to literal value.")
      else
        raise ParseError.new(current_location, "Invalid value for LHS of Assign: #{node}")
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
        # Only bare calls with identifier names can be used as bindings in a
        # pattern.
        if node.name.is_a?(Node)
          raise ParseError.new(node.location.not_nil!, "Expression calls are not allowed in patterns.")
        elsif node.receiver? || node.block? || !node.args.empty?
          raise ParseError.new(node.location.not_nil!, "Calls are not allowed in patterns.")
        else
          push_local_var(node.name.as(String))
          return Var.new(node.name.as(String)).at(node)
        end
      when ListLiteral
        node.elements = node.elements.map { |e| to_pattern(e).as(Node) }
        has_splat = false
        node.elements.each do |el|
          if el.is_a?(Splat)
            if has_splat
              raise ParseError.new(el.location.not_nil!, "List patterns may only contain a single Splat.")
            else
              has_splat = true
            end
          end
        end
      when MapLiteral
        node.entries = node.entries.map { |e| MapLiteral::Entry.new(e.key, to_pattern(e.value).as(Node)) }
      when Splat
        node.value = to_pattern(node.value)
      end

      return node
    end



    ###
    # Utilities
    #
    # Utility methods for managing the state of the parser or for making
    # complex assertions on values.
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

    # Returns true if the given identifier is modified (i.e., ends with a
    # `?` or `!`).
    def modified_ident?(ident : String)
      ident.ends_with?('?') || ident.ends_with?('!')
    end
  end
end
