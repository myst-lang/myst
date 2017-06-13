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
      if @current_token.type == type
        advance
      end
    end

    def expect(type : Token::Type)
      current_type = @current_token.type
      raise ParseError.new(current_type, type) unless accept(type)
    end


    def parse_block : AST::Block
      block = AST::Block.new([] of AST::Node)

      until @current_token.type == Token::Type::EOF
        block.children << parse_expression
      end

      block
    end

    def parse_statement
      expr = parse_expression
      expect(Token::Type::NEWLINE)
      expr
    end

    def parse_expression
      parse_assignment_expression
    end

    def parse_assignment_expression
      left = parse_additive_expression
      case current_token.type
      when Token::Type::EQUAL
        advance
        right = parse_assignment_expression
        return AST::SimpleAssignment.new(left, right)
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
        return parse_primary_expression
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
      when Token::Type::LPAREN
        expect(Token::Type::LPAREN)
        expression = parse_expression
        expect(Token::Type::RPAREN)
        return expression
      when Token::Type::IDENT
        token = current_token
        advance
        return AST::VariableReference.new(token.value)
      else
        raise ParseError.new(current_token.type)
      end
    end
  end
end
