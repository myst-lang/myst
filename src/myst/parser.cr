require "./parser/*"
require "./ast"

module Myst
  class Parser < Lexer
    property current_token  : Token

    SKIPPED_TOKENS = [
      Token::Type::WHITESPACE,
      Token::Type::NEWLINE
    ]


    def initialize(source : IO::Memory)
      super
      # Immediately consume a token to set `current_token`.
      advance
    end


    def advance
      while SKIPPED_TOKENS.includes?(read_token.type)
      end
      @current_token
    end

    def accept(type : Token::Type)
      token = @current_token
      if token.type == type
        advance
        token
      else
        false
      end
    end

    def expect(type : Token::Type)
      token = @current_token
      raise ParseError.new(token.type, type) unless accept(type)
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
      when Token::Type::DEF
        parse_function_definition
      when Token::Type::IF, Token::Type::UNLESS
        parse_conditional_expression
      when Token::Type::WHILE, Token::Type::UNTIL
        parse_conditional_loop
      else
        expr = parse_expression
      end
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

    def parse_function_args
      args = AST::ExpressionList.new([] of AST::Node)
      if accept(Token::Type::LPAREN)
        return args if accept(Token::Type::RPAREN)
        args = parse_expression_list
        expect(Token::Type::RPAREN)
        return args
      else
        return args if accept(Token::Type::NEWLINE)
        args = parse_expression_list
        return args
      end
    end

    # Function parameters can include named arguments, defaults, type
    # restrictions, patterns, and guard clauses, while function arguments
    # can only be regular expressions. As such, the two must be parsed
    # independently.
    def parse_parameter_list
      args = [] of AST::FunctionParameter
      args << parse_parameter
      while current_token.type == Token::Type::COMMA
        advance
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

    def parse_expression_list
      args = [] of AST::Node
      args << parse_expression
      # Expressions are delimited by commas. If no comma follows an
      # expression, the list has been fully consumed.
      while current_token.type == Token::Type::COMMA
        advance
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
        right = parse_assignment_expression
        return AST::SimpleAssignment.new(left, right)
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
        return AST::UnaryExpression.new(operator, parse_primary_expression)
      else
        return parse_postfix_expression
      end
    end

    def parse_postfix_expression
      receiver = parse_primary_expression
      case (operator = current_token).type
      when Token::Type::LPAREN
        args = parse_function_args
        return AST::FunctionCall.new(receiver, args)
      when Token::Type::LBRACE
        expect(Token::Type::LBRACE)
        key = parse_expression
        expect(Token::Type::RBRACE)
        if current_token.type == Token::Type::EQUAL
          advance
          value = parse_expression
          return AST::AccessSetExpression.new(receiver, key, value)
        end
        return AST::AccessExpression.new(receiver, key)
      else
        return receiver
      end
    end

    def parse_primary_expression
      case current_token.type
      when Token::Type::INTEGER
        token = current_token
        advance
        return AST::IntegerLiteral.new(token.value)
      when Token::Type::FLOAT
        token = current_token
        advance
        return AST::FloatLiteral.new(token.value)
      when Token::Type::STRING
        token = current_token
        advance
        return AST::StringLiteral.new(token.value)
      when Token::Type::SYMBOL
        token = current_token
        advance
        return AST::SymbolLiteral.new(token.value)
      when Token::Type::TRUE
        token = current_token
        advance
        return AST::BooleanLiteral.new(true)
      when Token::Type::FALSE
        token = current_token
        advance
        return AST::BooleanLiteral.new(false)
      when Token::Type::IDENT
        token = current_token
        advance
        return AST::VariableReference.new(token.value)
      when Token::Type::LPAREN
        expect(Token::Type::LPAREN)
        expression = parse_expression
        expect(Token::Type::RPAREN)
        return expression
      when Token::Type::LBRACE
        expect(Token::Type::LBRACE)
        elements = parse_expression_list
        expect(Token::Type::RBRACE)
        return AST::ListLiteral.new(elements)
      else
        raise ParseError.new(current_token.type)
      end
    end
  end
end
