require "./ast.cr"

module Myst
  class Parser < Lexer
    include AST

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


    def advance(allowed_tokens=Token::Type.ignorable)
      while allowed_tokens.includes?(read_token.type); end
      @current_token
    end

    def accept(*types : Token::Type, allow_newlines=true)
      token = @current_token
      if types.includes?(token.type)
        advance
        token
      else
        nil
      end
    end

    def expect(*types : Token::Type, allow_newlines=true)
      token = @current_token
      raise ParseError.new(token, types.to_a) unless accept(*types, allow_newlines: allow_newlines)
      token
    end

    # Parse the entirety of the given source. Currently, this assumes valid
    # input and will only end when an EOF is encountered.
    def parse
      program = Expressions.new
      until accept(Token::Type::EOF)
        program.children << parse_expression
      end

      program
    end

    def parse_expression
      literal = parse_literal
      advance
      return literal
    end

    def parse_literal
      literal =
        case current_token.type
        when Token::Type::NIL
          NilLiteral.new
        when Token::Type::TRUE
          BooleanLiteral.new(true)
        when Token::Type::FALSE
          BooleanLiteral.new(false)
        when Token::Type::INTEGER
          IntegerLiteral.new(current_token.value)
        when Token::Type::FLOAT
          FloatLiteral.new(current_token.value)
        when Token::Type::STRING
          StringLiteral.new(current_token.value)
        when Token::Type::SYMBOL
          SymbolLiteral.new(current_token.value)
        else
          raise ParseError.new(current_token, "Expected a literal value")
        end

      return literal.at(current_token.location)
    end
  end
end
