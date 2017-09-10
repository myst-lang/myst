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
      accept(*types) || raise ParseError.new("Expected one of #{types.join(',')}, got #{@current_token.type}")
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
      until accept(Token::Type::EOF)
        skip_space_and_newlines
        program.children << parse_expression
        skip_space_and_newlines
      end

      program
    end

    def parse_expression
      expr = parse_logical_or

      skip_space_and_newlines
      return expr
    end

    def parse_logical_or
      left = parse_logical_and
      skip_space_and_newlines

      if accept(Token::Type::OROR)
        skip_space_and_newlines
        right = parse_logical_or
        return Or.new(left, right).at(left).at_end(right)
      end

      return left
    end

    def parse_logical_and
      left = parse_equality
      skip_space_and_newlines

      if accept(Token::Type::ANDAND)
        skip_space_and_newlines
        right = parse_logical_and
        return And.new(left, right).at(left).at_end(right)
      end

      return left
    end

    def parse_equality
      left = parse_comparative
      skip_space_and_newlines

      if op = accept(Token::Type::EQUALEQUAL, Token::Type::NOTEQUAL)
        skip_space_and_newlines
        right = parse_equality
        return Call.new(left, op.value, [right] of Node).at(left).at_end(right)
      end

      return left
    end

    def parse_comparative
      left = parse_additive
      skip_space_and_newlines

      if op = accept(Token::Type::LESS, Token::Type::LESSEQUAL, Token::Type::GREATEREQUAL, Token::Type::GREATER)
        skip_space_and_newlines
        right = parse_comparative
        return Call.new(left, op.value, [right] of Node).at(left).at_end(right)
      end

      return left
    end

    def parse_additive(left=nil)
      left ||= parse_multiplicative
      skip_space_and_newlines

      if op = accept(Token::Type::PLUS, Token::Type::MINUS)
        skip_space_and_newlines
        right = parse_additive
        return Call.new(left, op.value, [right] of Node).at(left).at_end(right)
      end

      return left
    end

    def parse_multiplicative(left=nil)
      left ||= parse_primary
      skip_space_and_newlines

      if op = accept(Token::Type::STAR, Token::Type::SLASH, Token::Type::MODULO)
        skip_space_and_newlines
        right = parse_multiplicative
        return Call.new(left, op.value, [right] of Node).at(left).at_end(right)
      end

      return left
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
      literal =
          case (token = current_token).type
          when Token::Type::NIL
            read_token
            NilLiteral.new
          when Token::Type::TRUE
            read_token
            BooleanLiteral.new(true)
          when Token::Type::FALSE
            read_token
            BooleanLiteral.new(false)
          when Token::Type::INTEGER
            read_token
            IntegerLiteral.new(token.value)
          when Token::Type::FLOAT
            read_token
            FloatLiteral.new(token.value)
          when Token::Type::STRING
            read_token
            StringLiteral.new(token.value)
          when Token::Type::SYMBOL
            read_token
            SymbolLiteral.new(token.value)
          when Token::Type::LBRACE
            parse_list_literal
          when Token::Type::LCURLY
            parse_map_literal
          else
            raise ParseError.new("Expected a literal value. Got #{current_token.inspect} instead")
          end

      return literal.at(current_token.location)
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
