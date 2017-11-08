require "./token"
require "./exceptions"
require "./reader"

module Myst
  class Lexer
    # Source code being lexed.
    property reader : Reader
    # Full path to the source file used by this lexer. For STDIN and other
    # non-local input methods, this will be `nil`.
    property source_file : String

    # Current line number in the source.
    property row : Int32
    # Current column number in the source.
    property col : Int32
    # Current character in the source.
    property last_char : Char

    # Token currently being parsed.
    property current_token : Token
    # List of tokens already parsed.
    property tokens : Array(Token)



    def initialize(source : IO, source_file : String, row_start=1, col_start=0)
      @reader = Reader.new(source)
      @source_file = File.expand_path(source_file)

      @row = row_start
      @col = col_start
      @last_char = ' '

      # TODO: re-assignment to @current_token is currently necessary because
      # Crystal does not understand that the ivar is being initialized in
      # `advance_token`. I believe this is being addressed in 0.24.0.
      @current_token = advance_token
      @buffer = IO::Memory.new
      @tokens = [] of Token
    end

    def lex_all
      until @current_token.type == Token::Type::EOF
        read_token
      end
    end

    # Move to a new token with a new buffer.
    def advance_token
      @current_token = Token.new(location: Location.new(@source_file, @row, @col))
    end

    def current_char : Char
      @reader.current_char
    end

    def current_location
      @current_token.location
    end

    # Consume a single character from the source.
    def read_char : Char
      last_char = current_char
      if last_char == '\n'
        @row += 1
        @col = 0
      end

      @col += 1
      @current_token.location.length += 1

      @reader.read_char
    end

    def peek_char : Char
      @reader.peek_char
    end

    def finished? : Bool
      @reader.finished?
    end

    # Consume and store a single token from the source.
    def read_token : Token
      advance_token

      # By default, assume a token will be an identifier
      @current_token.type = Token::Type::IDENT

      case current_char
      when '\0'
        @current_token.type = Token::Type::EOF
        read_char
      when ','
        @current_token.type = Token::Type::COMMA
        read_char
      when '.'
        @current_token.type = Token::Type::POINT
        read_char
      when '&'
        @current_token.type = Token::Type::AMPERSAND
        read_char
        if current_char == '&'
          @current_token.type = Token::Type::ANDAND
          read_char
          if current_char == '='
            @current_token.type = Token::Type::ANDOP
            read_char
          end
        end
      when '|'
        @current_token.type = Token::Type::PIPE
        read_char
        if current_char == '|'
          @current_token.type = Token::Type::OROR
          read_char
          if current_char == '='
            @current_token.type = Token::Type::OROP
            read_char
          end
        end
      when '='
        @current_token.type = Token::Type::EQUAL
        read_char
        case current_char
        when '='
          @current_token.type = Token::Type::EQUALEQUAL
          read_char
        when ':'
          @current_token.type = Token::Type::MATCH
          read_char
        end
      when '!'
        @current_token.type = Token::Type::NOT
        read_char
        if current_char == '='
          @current_token.type = Token::Type::NOTEQUAL
          read_char
        end
      when '<'
        @current_token.type = Token::Type::LESS
        read_char
        if current_char == '='
          @current_token.type = Token::Type::LESSEQUAL
          read_char
        end
      when '>'
        @current_token.type = Token::Type::GREATER
        read_char
        if current_char == '='
          @current_token.type = Token::Type::GREATEREQUAL
          read_char
        end
      when '+'
        @current_token.type = Token::Type::PLUS
        read_char
        if current_char == '='
          @current_token.type = Token::Type::PLUSOP
          read_char
        end
      when '-'
        @current_token.type = Token::Type::MINUS
        read_char
        if current_char == '='
          @current_token.type = Token::Type::MINUSOP
          read_char
        end
      when '*'
        @current_token.type = Token::Type::STAR
        read_char
        if current_char == '='
          @current_token.type = Token::Type::STAROP
          read_char
        end
      when '/'
        @current_token.type = Token::Type::SLASH
        read_char
        if current_char == '='
          @current_token.type = Token::Type::SLASHOP
          read_char
        end
      when '%'
        @current_token.type = Token::Type::MODULO
        read_char
        if current_char == '='
          @current_token.type = Token::Type::MODOP
          read_char
        end
      when '\n'
        @current_token.type = Token::Type::NEWLINE
        read_char
      when '#'
        @current_token.type = Token::Type::COMMENT
        consume_comment
      when '"'
        @current_token.type = Token::Type::STRING
        consume_string
      when ':'
        consume_symbol_or_colon
      when ';'
        @current_token.type = Token::Type::SEMI
        read_char
      when '('
        @current_token.type = Token::Type::LPAREN
        read_char
      when ')'
        @current_token.type = Token::Type::RPAREN
        read_char
      when '['
        @current_token.type = Token::Type::LBRACE
        read_char
      when ']'
        @current_token.type = Token::Type::RBRACE
        read_char
      when '{'
        @current_token.type = Token::Type::LCURLY
        read_char
      when '}'
        @current_token.type = Token::Type::RCURLY
        read_char
      when .ascii_number?
        consume_numeric
      when .ascii_whitespace?
        consume_whitespace
      when .ascii_uppercase?
        consume_constant
      when '@'
        @current_token.type = Token::Type::IVAR
        read_char
        consume_identifier
      else
        # Everything else should be tried as either a keyword or an identifier.
        # First, attempt to lex an identifier, then check if the identifier as
        # a whole constitutes a keyword. This should prevent misclassifications
        # for sequences like `definition` and `required` that would otherwise
        # be considered a keyword followed by an identifier.
        consume_identifier
        check_for_keyword
      end

      finalize_token
    end

    # Assign the tokens final value and add it to the consumed tokens list.
    def finalize_token
      @current_token.raw = @reader.buffer_value

      @reader.buffer.clear
      @reader.buffer << current_char

      @tokens << @current_token
      @current_token
    end

    # Attempt to lex the current buffer as a keyword. If one is found, the
    # token type will be set appropriately. If not, the token type will not
    # be changed.
    def check_for_keyword
      if kw_type = Token::Type.keyword_map[@reader.buffer_value]?
        @current_token.type = kw_type
      end
    end


    def consume_numeric
      has_decimal = false

      loop do
        case current_char
        when '.'
          if !has_decimal && peek_char.ascii_number?
            read_char
            has_decimal = true
          else
            assign_numeric_value(has_decimal)
            break
          end
        when '_'
          read_char
        when .ascii_number?
          read_char
        else
          break
        end
      end

      assign_numeric_value(has_decimal)
    end

    private def assign_numeric_value(has_decimal)
      @current_token.value = @reader.buffer_value.tr("_", "")
      @current_token.type = has_decimal ? Token::Type::FLOAT : Token::Type::INTEGER
    end

    def consume_string
      # Read the starting quote character
      read_char

      # The stack of bracing characters that have been encountered so far. When
      # an opening brace is encountered (`{`), it is pushed here. When a
      # matching closing brace is found (`}`), it's opener is popped.
      #
      # Note that this intentionally does _not_ allow early termination of the
      # string. All braces must be matched for the string to finish. Otherwise,
      # the string will continue to the end of the input sequence (potentially
      # infinite). To ensure this does not block indefinitely, an error is
      # raised if a null character (`\0`) is found.
      brace_stack = ['"'] of Char


      loop do
        if brace_stack.empty?
          break
        end

        case current_char
        when '\0'
          # A null character within a string is a syntax error.
          raise SyntaxError.new(current_location, "Unterminated string literal. Reached EOF without terminating.")
          # Read the closing quote, then stop
          read_char
          break
        when '\\'
          # Read two characters to naively support escaped characters.
          # This ensures that escaped quotes do not terminate the string.
          read_char
          read_char
        when '#'
          read_char
          if current_char == '{'
            brace_stack.push('{')
          end
        when '}'
          read_char
          if brace_stack.last == '{'
            brace_stack.pop
          end
        when '"'
          read_char
          if brace_stack.last == '"'
            brace_stack.pop
          end
        else
          read_char
        end
      end

      # Replace escape codes
      @current_token.value = @reader.buffer_value.gsub(/\\./) do |code|
        case code
        when "\\n"  then '\n'
        when "\\\"" then '"'
        when "\\t"  then '\t'
        when "\\0"  then '\0'
        end
      end

      # Strip the containing quote characters
      @current_token.value = @current_token.value[1..-2]
    end

    def consume_symbol_or_colon
      # Read the starting colon
      read_char

      force_symbol = false
      case current_char
      when '"'
        # Quoted values allow for arbitrary symbol names. An empty string (:"")
        # will still be considered a symbol
        consume_string
        force_symbol = true
      when .ascii_whitespace?
      when '\0'
        # A colon followed immediately by whitespace should not be a symbol.
        # The empty string notation shown above should be used for symbols with
        # no value.
      else
        consume_identifier
      end

      if force_symbol || @current_token.value.size > 1
        @current_token.type = Token::Type::SYMBOL
        @current_token.value = @current_token.value[1..-1]
      else
        @current_token.type = Token::Type::COLON
      end
    end

    def consume_comment
      until ['\n', '\0'].includes?(read_char); end
    end

    def consume_whitespace
      @current_token.type = Token::Type::WHITESPACE
      while (c = read_char).ascii_whitespace? && c != '\n'; end
    end

    def consume_constant
      # Constants must start with an uppercase character, and may only contain
      # letters, numbers or underscores afterwards.
      if current_char.ascii_uppercase?
        read_char
      else
        raise SyntaxError.new(current_location, "Unexpected character `#{current_char}` for CONST. Current buffer: `#{@reader.buffer_value}`.")
      end

      @current_token.type = Token::Type::CONST

      loop do
        if current_char.ascii_alphanumeric? || current_char == '_'
          read_char
        else
          break
        end
      end

      @current_token.value = @reader.buffer_value
    end

    def consume_identifier
      # Identifiers must start with a letter or an underscore
      unless current_char.ascii_letter? || current_char == '_'
        raise SyntaxError.new(current_location, "Unexpected character `#{current_char}` for IDENT. Current buffer: `#{@reader.buffer_value}`.")
      end

      loop do
        if current_char.ascii_alphanumeric? || current_char == '_'
          read_char
        else
          break
        end
      end

      # Identifiers may end with a query (`?`) or bang (`!`) modifier as the
      # last character.
      if current_char == '?' || current_char == '!'
        read_char
      end

      @current_token.value = @reader.buffer_value
    end
  end
end
