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
      advance
    end



    ###
    # Movement
    #
    # Methods for moving through the source.
    ###

    def advance(allowed_tokens=Token::Type.ignorable, newlines=true)
      while allowed_tokens.includes?(read_token.type); end
      @current_token
    end

    def advance_with_newlines
      advance
    end

    def advance_without_newlines
      advance(newlines: false)
    end

    def accept(*types : Token::Type, newlines=true)
      token = @current_token
      if types.includes?(token.type)
        advance(newlines: newlines)
        token
      else
        nil
      end
    end

    def expect(*types : Token::Type, newlines=true)
      token = @current_token
      raise ParseError.new("Expected one of #{types}, got #{token}") unless accept(*types, newlines: newlines)
      token
    end



    ###
    # Parsers
    #
    # Methods for parsing source material into nodes.
    ###

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
      expr = case current_token.type
      when Token::Type::IDENT
        parse_var_or_call
      else
        parse_literal
      end

      advance_with_newlines

      return expr
    end

    def parse_var_or_call
      name = expect(Token::Type::IDENT).value

      if name.starts_with?('_')
        return Underscore.new(name)
      end

      if is_local_var?(name)
        return Var.new(name)
      end

      return Call.new(nil, name)
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
          raise ParseError.new("Expected a literal value. Got #{current_token} instead")
        end

      return literal.at(current_token.location)
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
