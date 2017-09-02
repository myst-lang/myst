require "./parser/*"
require "./ast"

module Myst
  class Parser < Lexer
    property current_token  : Token
    property allow_newlines : Bool = true

    SKIPPED_TOKENS = [
      Token::Type::WHITESPACE,
      Token::Type::NEWLINE,
      Token::Type::COMMENT
    ]

    def self.for_file(source_file)
      new(File.open(source_file), source_file, File.expand_path(File.dirname(source_file)))
    end

    def initialize(source : IO, working_dir : String)
      super(source, working_dir: working_dir)
      # Immediately consume a token to set `current_token`.
      advance
    end

    def initialize(source : IO, source_file : String, working_dir : String)
      super(source, source_file, working_dir)
      advance
    end

    def advance(allowed_tokens=SKIPPED_TOKENS)
      allowed_tokens -= [Token::Type::NEWLINE] unless @allow_newlines
      while allowed_tokens.includes?(read_token.type); end
      @current_token
    end

    def accept(*types : Token::Type)
      token = @current_token
      if types.includes?(token.type)
        advance
        token
      else
        nil
      end
    end

    def expect(*types : Token::Type)
      token = @current_token
      raise ParseError.new(token, types.to_a) unless accept(*types)
      token
    end


    def parse_block(terminators = [] of Token::Type) : AST::Block
      terminators << Token::Type::END

      block = AST::Block.new([] of AST::Node)

      until @current_token.type == Token::Type::EOF || terminators.includes?(@current_token.type)
        block.children << parse_statement
      end

      block
    end

    def parse_statement
      case current_token.type
      when Token::Type::REQUIRE
        parse_require_statement
      when Token::Type::MODULE
        parse_module_definition
      when Token::Type::INCLUDE
        parse_include_statement
      when Token::Type::DEF
        parse_function_definition
      when Token::Type::IF, Token::Type::UNLESS
        parse_conditional_expression
      when Token::Type::WHILE, Token::Type::UNTIL
        parse_conditional_loop
      else
        parse_expression
      end
    end

    def expect_delimiter
      expect(Token::Type::NEWLINE)
    end

    def parse_require_statement
      expect(Token::Type::REQUIRE)
      path = parse_expression
      return AST::RequireStatement.new(path, @working_dir)
    end

    def parse_include_statement
      expect(Token::Type::INCLUDE)
      mod = parse_module_reference
      return AST::IncludeStatement.new(mod)
    end

    # This is essentially a special-case of `parse_postfix_expression` to only
    # allow member accesses with Constants, e.g. `HTTP.WebSocket.Response`
    def parse_module_reference
      root = expect(Token::Type::CONST).value
      module_reference = AST::Const.new(root)
      while accept(Token::Type::POINT)
        member = expect(Token::Type::CONST).value
        module_reference = AST::MemberAccessExpression.new(module_reference, member)
      end
      module_reference
    end

    def parse_module_definition
      @allow_newlines = false
      expect(Token::Type::MODULE)
      name = expect(Token::Type::CONST).value
      @allow_newlines = true
      expect(Token::Type::NEWLINE)
      body = parse_block
      expect(Token::Type::END)

      return AST::ModuleDefinition.new(name, body)
    end

    def parse_function_definition
      @allow_newlines = false
      expect(Token::Type::DEF)
      name = expect(Token::Type::IDENT).value
      @allow_newlines = true

      parameters = [] of AST::Pattern
      if accept(Token::Type::LPAREN)
        # If the next token is a closing parenthesis, don't expect arguments.
        unless accept(Token::Type::RPAREN)
          parameters = parse_parameter_list
          expect(Token::Type::RPAREN)
        end
      else
        expect(Token::Type::NEWLINE)
      end

      body = parse_block

      expect(Token::Type::END)

      return AST::FunctionDefinition.new(name, parameters, body)
    end

    # Function parameters can include named arguments, defaults, type
    # restrictions, patterns, and guard clauses, while function arguments
    # can only be regular expressions. As such, the two must be parsed
    # independently.
    def parse_parameter_list
      params = [] of AST::Pattern
      params << parse_parameter
      while accept(Token::Type::COMMA)
        params << parse_parameter
      end
      return params
    end

    def parse_parameter
      # Currently parameters can only be identifiers, patterns, or a
      # pattern-matching assignment expression.
      #
      # If an identifier is the first token encountered, a pattern match is not
      # allowed (as it would be redundant; e.g. `name1 =: name2`).
      param = case current_token.type
              when Token::Type::IDENT
                name = current_token
                advance
                AST::Pattern.new(name: AST::Ident.new(name.value))
              when Token::Type::STAR
                advance
                name = current_token
                advance
                AST::Pattern.new(name: AST::Ident.new(name.value), splat: true)
              when Token::Type::AMPERSAND
                advance
                name = current_token
                advance
                AST::Pattern.new(name: AST::Ident.new(name.value), block: true)
              else
                # Parameters not starting with an identifier are assumed to start with
                # a pattern. If a pattern is given, it may optionally be followed by a
                # name after a match operator.
                begin
                  p = AST::Pattern.new
                  p.pattern = parse_primary_expression
                  if accept(Token::Type::MATCH)
                    name = expect(Token::Type::IDENT).value
                    p.name = AST::Ident.new(name)
                  end

                  p
                rescue ParseError
                  raise "Type restrictions and guard clauses in function parameters are not yet supported."
                end
              end

      # All formats of function parameters also contain a type restriction. The
      # format for a type restriction is `param : Type`, where `param` is any
      # of the formats described above.
      if accept(Token::Type::COLON)
        name = expect(Token::Type::CONST).value
        param.type_restriction = AST::Const.new(name)
      end

      param
    end

    def parse_map_entry_list
      args = [] of AST::Node
      args << parse_map_entry
      while accept(Token::Type::COMMA)
        args << parse_map_entry
      end
      return AST::ExpressionList.new(args)
    end

    def parse_map_entry
      if accept(Token::Type::LESS)
        key = parse_value_interpolation_expression
        expect(Token::Type::GREATER)
      else
        key = AST::SymbolLiteral.new(current_token.value)
        read_token
      end
      expect(Token::Type::COLON)
      value = parse_expression
      return AST::MapEntryDefinition.new(key, value)
    end

    def parse_value_interpolation_expression
      interp = parse_postfix_expression
      return AST::ValueInterpolation.new(interp)
    end

    def parse_expression_list
      args = [] of AST::Node
      args << parse_expression
      # Expressions are delimited by commas. If no comma follows an
      # expression, the list has been fully consumed.
      while accept(Token::Type::COMMA)
        args << parse_expression
      end
      return AST::ExpressionList.new(args)
    end

    def parse_expression
      parse_assignment_expression
    end

    def parse_assignment_expression
      left = parse_logical_or_expression
      case current_token.type
      when Token::Type::EQUAL
        advance
        right = parse_expression
        return AST::SimpleAssignment.new(left, right)
      when Token::Type::MATCH
        advance
        right = parse_expression
        return AST::PatternMatchingAssignment.new(left, right)
      else
        return left
      end
    end

    def parse_conditional_expression
      case current_token.type
      when Token::Type::IF
        advance
        condition = parse_expression
        body = parse_block([Token::Type::ELSE, Token::Type::ELIF])
        alternative = parse_conditional_alternative
        expect(Token::Type::END)
        return AST::IfExpression.new(condition, body, alternative)
      when Token::Type::UNLESS
        advance
        condition = parse_expression
        body = parse_block([Token::Type::ELSE, Token::Type::ELIF])
        alternative = parse_conditional_alternative
        expect(Token::Type::END)
        return AST::UnlessExpression.new(condition, body, alternative)
      else
        return parse_logical_or_expression
      end
    end

    def parse_conditional_alternative
      case current_token.type
      when Token::Type::ELIF
        advance
        condition = parse_expression
        body = parse_block([Token::Type::ELSE, Token::Type::ELIF])
        alternative = parse_conditional_alternative
        return AST::ElifExpression.new(condition, body, alternative)
      when Token::Type::ELSE
        advance
        body = parse_block
        return AST::ElseExpression.new(body)
      when Token::Type::END
        return nil
      else
        raise ParseError.new(current_token, [Token::Type::ELSE, Token::Type::ELIF, Token::Type::END])
      end
    end

    def parse_conditional_loop
      case current_token.type
      when Token::Type::WHILE
        advance
        condition = parse_expression
        body = parse_block
        expect(Token::Type::END)
        return AST::WhileExpression.new(condition, body)
      when Token::Type::UNTIL
        advance
        condition = parse_expression
        body = parse_block
        expect(Token::Type::END)
        return AST::UntilExpression.new(condition, body)
      else
        return parse_logical_or_expression
      end
    end

    def parse_logical_or_expression
      left = parse_logical_and_expression
      case (operator = current_token).type
      when Token::Type::OROR
        advance
        right = parse_logical_or_expression
        return AST::LogicalExpression.new(operator, left, right)
      else
        return left
      end
    end

    def parse_logical_and_expression
      left = parse_equality_operation
      case (operator = current_token).type
      when Token::Type::ANDAND
        advance
        right = parse_logical_and_expression
        return AST::LogicalExpression.new(operator, left, right)
      else
        return left
      end
    end

    def parse_equality_operation
      left = parse_relational_expression
      case (operator = current_token).type
      when Token::Type::EQUALEQUAL, Token::Type::NOTEQUAL
        advance
        right = parse_equality_operation
        return AST::EqualityExpression.new(operator, left, right)
      else
        return left
      end
    end

    def parse_relational_expression
      left = parse_additive_expression
      case (operator = current_token).type
      when Token::Type::LESS, Token::Type::LESSEQUAL, Token::Type::GREATER, Token::Type::GREATEREQUAL
        advance
        right = parse_additive_expression
        return AST::RelationalExpression.new(operator, left, right)
      else
        return left
      end
    end

    def parse_additive_expression
      left = parse_multiplicative_expression
      case (operator = current_token).type
      when Token::Type::PLUS, Token::Type::MINUS
        advance
        right = parse_additive_expression
        return AST::BinaryExpression.new(operator, left, right)
      else
        return left
      end
    end

    def parse_multiplicative_expression
      left = parse_unary_expression
      case (operator = current_token).type
      when Token::Type::STAR, Token::Type::SLASH
        advance
        right = parse_multiplicative_expression
        return AST::BinaryExpression.new(operator, left, right)
      else
        return left
      end
    end

    def parse_unary_expression
      if (operator = current_token).type.unary_operator?
        @allow_newlines = false
        advance
        @allow_newlines = true
        return AST::UnaryExpression.new(operator, parse_unary_expression)
      else
        return parse_postfix_expression
      end
    end

    def parse_postfix_expression(receiver : AST::Node? = nil)
      # Postfix expressions must _start_ on the same line as their receiver.
      # After the expression has started, newlines are allowed.
      @allow_newlines = false
      receiver ||= parse_primary_expression
      # After the receiver has been parsed, `current_token` must be a postfix
      # operator to create a postfix expression. After the operator, newlines
      # are allowed, so they can be enabled here in advance.
      @allow_newlines = true

      expr = case
      when accept(Token::Type::POINT)
        member = expect(Token::Type::IDENT, Token::Type::CONST).value
        if accept(Token::Type::EQUAL)
          value = parse_expression
          return AST::MemberAssignmentExpression.new(receiver, member, value)
        else
          return parse_postfix_expression(AST::MemberAccessExpression.new(receiver, member))
        end
      when accept(Token::Type::LPAREN)
        if accept(Token::Type::RPAREN)
          args = AST::ExpressionList.new([] of AST::Node)
        else
          args = parse_expression_list
          @allow_newlines = false
          expect(Token::Type::RPAREN)
        end
        block = parse_optional_block
        return parse_postfix_expression(AST::FunctionCall.new(receiver, args, block))
      when accept(Token::Type::LBRACE)
        key = parse_expression
        @allow_newlines = false
        expect(Token::Type::RBRACE)
        if accept(Token::Type::EQUAL)
          value = parse_expression
          return AST::AccessSetExpression.new(receiver, key, value)
        else
          return parse_postfix_expression(AST::AccessExpression.new(receiver, key))
        end
      else
        # If this is _not_ a postfix expression, advance again to consume any
        # newlines that may have been missed while assuming this was a postfix
        # expression.
        accept(Token::Type::NEWLINE)
        return receiver
      end
    end

    def parse_primary_expression
      case
      when token = accept(Token::Type::INTEGER)
        return AST::IntegerLiteral.new(token.value)
      when token = accept(Token::Type::FLOAT)
        return AST::FloatLiteral.new(token.value)
      when token = accept(Token::Type::STRING)
        return AST::StringLiteral.new(token.value)
      when token = accept(Token::Type::SYMBOL)
        return AST::SymbolLiteral.new(token.value)
      when accept(Token::Type::TRUE)
        return AST::BooleanLiteral.new(true)
      when accept(Token::Type::FALSE)
        return AST::BooleanLiteral.new(false)
      when token = accept(Token::Type::IDENT)
        return AST::Ident.new(token.value)
      when token = accept(Token::Type::CONST)
        return AST::Const.new(token.value)
      when accept(Token::Type::LESS)
        @allow_newlines = true
        accept(Token::Type::NEWLINE)
        expression = parse_value_interpolation_expression
        expect(Token::Type::GREATER)
        return expression
      when accept(Token::Type::LPAREN)
        @allow_newlines = true
        accept(Token::Type::NEWLINE)
        expression = parse_expression
        expect(Token::Type::RPAREN)
        return expression
      when accept(Token::Type::LBRACE)
        @allow_newlines = true
        accept(Token::Type::NEWLINE)
        if accept(Token::Type::RBRACE)
          elements = AST::ExpressionList.new([] of AST::Node)
        else
          elements = parse_expression_list
          expect(Token::Type::RBRACE)
        end
        return AST::ListLiteral.new(elements)
      when accept(Token::Type::LCURLY)
        @allow_newlines = true
        accept(Token::Type::NEWLINE)
        if accept(Token::Type::RCURLY)
          elements = AST::ExpressionList.new([] of AST::Node)
        else
          elements = parse_map_entry_list
          expect(Token::Type::RCURLY)
        end
        return AST::MapLiteral.new(elements)
      else
        raise ParseError.new(current_token)
      end
    end


    def parse_optional_block
      params = [] of AST::Pattern

      @allow_newlines = false
      if block_start = accept(Token::Type::DO)
        @allow_newlines = true
        block_name = "block@#{block_start.location.to_s}"

        if accept(Token::Type::PIPE)
          unless accept(Token::Type::PIPE)
            params = parse_parameter_list
            expect(Token::Type::PIPE)
          end
        else
          @allow_newlines = true
          advance
        end

        body = parse_block
        expect(Token::Type::END)

        return AST::FunctionDefinition.new(block_name, params, body)
      else
        return nil
      end
    end
  end
end
