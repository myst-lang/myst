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
      new(File.open(source_file), File.expand_path(File.dirname(source_file)))
    end

    def initialize(source : IO, working_dir : String)
      super(source, working_dir: working_dir)
      # Immediately consume a token to set `current_token`.
      advance
    end

    def advance(allowed_tokens=SKIPPED_TOKENS)
      allowed_tokens -= [Token::Type::NEWLINE] unless @allow_newlines
      while allowed_tokens.includes?(read_token.type); end
      @current_token
    end

    def accept(type : Token::Type)
      token = @current_token
      if token.type == type
        advance
        token
      else
        nil
      end
    end

    def expect(type : Token::Type)
      token = @current_token
      raise ParseError.new(token, type) unless accept(type)
      token
    end


    def parse_block : AST::Block
      block = AST::Block.new([] of AST::Node)

      until @current_token.type == Token::Type::EOF || @current_token.type.block_terminator?
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

    def parse_require_statement
      expect(Token::Type::REQUIRE)
      path = parse_expression
      return AST::RequireStatement.new(path, @working_dir)
    end

    def parse_module_definition
      expect(Token::Type::MODULE)
      name = expect(Token::Type::IDENT).value
      body = parse_block
      expect(Token::Type::END)

      return AST::ModuleDefinition.new(name, body)
    end

    def parse_function_definition
      expect(Token::Type::DEF)
      name = expect(Token::Type::IDENT).value
      paren_wrapped = accept(Token::Type::LPAREN)
      parameters = parse_parameter_list
      expect(Token::Type::RPAREN) if paren_wrapped
      body = parse_block

      expect(Token::Type::END)

      return AST::FunctionDefinition.new(name, parameters, body)
    end

    # Function parameters can include named arguments, defaults, type
    # restrictions, patterns, and guard clauses, while function arguments
    # can only be regular expressions. As such, the two must be parsed
    # independently.
    def parse_parameter_list
      args = [] of AST::FunctionParameter
      args << parse_parameter
      while accept(Token::Type::COMMA)
        args << parse_parameter
      end
      return AST::ParameterList.new(args)
    end

    def parse_parameter
      # Currently parameters can only be simple identifiers
      case current_token.type
      when Token::Type::IDENT
        token = current_token
        advance
        return AST::FunctionParameter.new(token.value)
      else
        raise "Advanced function parameters are not yet supported."
      end
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
      case current_token.type
      when Token::Type::YIELD
        @allow_newlines = false
        advance
        @allow_newlines = true
        if accept(Token::Type::LPAREN)
          args = parse_expression_list
          expect(Token::Type::RPAREN)
        else
          args = AST::ExpressionList.new([] of AST::Node)
          accept(Token::Type::NEWLINE)
        end

        return AST::YieldExpression.new(args)
      else
        parse_assignment_expression
      end
    end

    def parse_assignment_expression
      left = parse_logical_or_expression
      case current_token.type
      when Token::Type::EQUAL
        advance
        right = parse_assignment_expression
        return AST::SimpleAssignment.new(left, right)
      when Token::Type::MATCH
        advance
        right = parse_assignment_expression
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
        body = parse_block
        alternative = parse_conditional_alternative
        expect(Token::Type::END)
        return AST::IfExpression.new(condition, body, alternative)
      when Token::Type::UNLESS
        advance
        condition = parse_expression
        body = parse_block
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
        body = parse_block
        alternative = parse_conditional_alternative
        return AST::ElifExpression.new(condition, body, alternative)
      when Token::Type::ELSE
        advance
        body = parse_block
        return AST::ElseExpression.new(body)
      when Token::Type::END
        return nil
      else
        raise "Unexpected token `#{current_token}`. Expected `ELSE`, `ELIF`, or `END`."
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
        advance
        return AST::UnaryExpression.new(operator, parse_postfix_expression)
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
        member = expect(Token::Type::IDENT).value
        return parse_postfix_expression(AST::MemberAccessExpression.new(receiver, member))
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
          return parse_postfix_expression(AST::AccessSetExpression.new(receiver, key, value))
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
        return AST::VariableReference.new(token.value)
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
        end
        expect(Token::Type::RCURLY)
        return AST::MapLiteral.new(elements)
      else
        raise ParseError.new(current_token)
      end
    end


    def parse_optional_block
      if block_start = accept(Token::Type::DO)
        block_name = "block@#{block_start.location.to_s}"
        @allow_newlines = false
        if accept(Token::Type::PIPE)
          params = parse_parameter_list
          @allow_newlines = true
          expect(Token::Type::PIPE)
        else
          params = AST::ParameterList.new([] of AST::FunctionParameter)
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
