require "./ast.cr"

module Myst
  class Parser < Lexer
    include AST

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
      block = Expressions.new
      skip_space_and_newlines
      until terminators.includes?(current_token.type)
        block.children << parse_expression
        expect_delimiter_or_eof
        skip_space_and_newlines
      end

      block
    end

    def parse_expression
      case current_token.type
      when Token::Type::DEF
        parse_def
      else
        parse_logical_or
      end
    end

    def parse_def
      start = expect(Token::Type::DEF)
      skip_space
      name = expect(Token::Type::IDENT).value
      skip_space
      method_def = Def.new(name).at(start.location)
      # If the Def has parameters, they must be parenthesized. If the token
      # after the opening parenthesis is a closing one, then there are no
      # parameters.
      if accept(Token::Type::LPAREN) && !accept(Token::Type::RPAREN)
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

      skip_space
      expect_delimiter_or_eof
      skip_space_and_newlines

      if finish = accept(Token::Type::END)
        method_def.body = Nop.new
        return method_def.at_end(finish.location)
      else
        method_def.body = parse_code_block(Token::Type::END)
        finish = expect(Token::Type::END)
        return method_def.at_end(finish.location)
      end
    end

    def parse_param(allow_splat=true)
      param = Param.new

      case
      when accept(Token::Type::STAR)
        if allow_splat
          param.splat = true
        else
          raise ParseError.new("Multiple splat parameters are not allowed in a definition.")
        end
      when accept(Token::Type::AMPERSAND)
        param.block = true
      end

      name = expect(Token::Type::IDENT)
      param.name = name.value
      return param.at(name.location)
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

    def parse_additive
      left = parse_multiplicative
      skip_space

      if op = accept(Token::Type::PLUS, Token::Type::MINUS)
        skip_space_and_newlines
        right = parse_additive
        return Call.new(left, op.value, [right] of Node).at(left).at_end(right)
      end

      return left
    end

    def parse_multiplicative
      left = parse_assign
      skip_space

      if op = accept(Token::Type::STAR, Token::Type::SLASH, Token::Type::MODULO)
        skip_space_and_newlines
        right = parse_multiplicative
        return Call.new(left, op.value, [right] of Node).at(left).at_end(right)
      end

      return left
    end

    def parse_assign
      target = parse_primary
      skip_space
      if accept(Token::Type::EQUAL)
        skip_space_and_newlines
        value = parse_expression
        return SimpleAssign.new(to_lhs(target), value).at(target).at_end(value)
      end

      return target
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
      when Token::Type::IDENT
        parse_var_or_call
      else
        parse_literal
      end
    end

    def parse_var_or_call
      token = expect(Token::Type::IDENT)
      name  = token.value

      if name.starts_with?('_')
        return Underscore.new(name).at(token.location)
      end

      if is_local_var?(name)
        return Var.new(name).at(token.location)
      end

      return Call.new(nil, name).at(token.location)
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
        map.elements << MapLiteral::Entry.new(key: key, value: value)
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
      name = expect(Token::Type::IDENT)
      # Symbol keys must be _immediately_ followed by a colon, with no spaces
      # between the two.
      expect(Token::Type::COLON)
      return SymbolLiteral.new(name.value).at(name.location).at_end(name.location)
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
