require "./parser/*"
require "./ast"

module Myst
  class Parser < Lexer
    include AST

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


    def parse
      program = Expressions.new
      until accept(Token::Type::EOF)
        program.children << parse_expression
      end

      program
    end

    def parse_expression
      advance
      Nop.new
    end
  end
end
