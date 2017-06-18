require "./token"
require "./exceptions"
require "./reader"

module Myst
  class Lexer
    # Source code being lexed.
    property reader : Reader
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


    def initialize(source : IO::Memory)
      @reader = Reader.new(source)

      @row = 1
      @col = 0
      @last_char = ' '

      @current_token = Token.new
      @buffer = IO::Memory.new
      @tokens = [] of Token
    end

    def lex_all
      until finished?
        read_token
      end
    end

    # Move to a new token with a new buffer.
    def advance_token
      @current_token = Token.new
      @current_token.location.line  = @row
      @current_token.location.col   = @col
    end

    def current_char : Char
      @reader.current_char
    end

    # Consume a single character from the source.
    def read_char : Char
      last_char = current_char
      if last_char == '\n'
        @row += 1
        @col = 0
      end

      @col += 1

      @reader.read_char
    end

    # Get the next character from the source without advancing the reader.
    # Returns a null byte if no characters remain.
    def peek_char : Char
      @reader.peek_char
    end

    def finished? : Bool
      @reader.finished?
    end

    # Consume and store a single token from the source.
    def read_token : Token
      advance_token

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
        end
      when '|'
        @current_token.type = Token::Type::PIPE
        read_char
        if current_char == '|'
          @current_token.type = Token::Type::OROR
          read_char
        end
      when '='
        @current_token.type = Token::Type::EQUAL
        read_char
        if current_char == '='
          @current_token.type = Token::Type::EQUALEQUAL
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
      when '-'
        @current_token.type = Token::Type::MINUS
        read_char
      when '*'
        @current_token.type = Token::Type::STAR
        read_char
      when '/'
        @current_token.type = Token::Type::SLASH
        read_char
      when '\n'
        @current_token.type = Token::Type::NEWLINE
        read_char
      when '"'
        @current_token.type = Token::Type::STRING
        consume_string
      when '('
        @current_token.type = Token::Type::LPAREN
        read_char
      when ')'
        @current_token.type = Token::Type::RPAREN
        read_char
      when 'd'
        if read_char == 'e' && read_char == 'f'
          read_char
          @current_token.type = Token::Type::DEF
        else
          consume_identifier
        end
      when 'e'
        read_char
        case current_char
        when 'l'
          read_char
          case current_char
          when 'i'
            if read_char == 'f'
              read_char
              @current_token.type = Token::Type::ELIF
            else
              consume_identifier
            end
          when 's'
            if read_char == 'e'
              read_char
              @current_token.type = Token::Type::ELSE
            else
              consume_identifier
            end
          else
            consume_identifier
          end
        when 'n'
          if read_char == 'd'
            read_char
            @current_token.type = Token::Type::END
          else
            consume_identifier
          end
        else
          consume_identifier
        end
      when 'f'
        if read_char == 'a' && read_char == 'l' && read_char == 's' && read_char == 'e'
          read_char
          @current_token.type = Token::Type::FALSE
        else
          consume_identifier
        end
      when 'i'
        if read_char == 'f'
          read_char
          @current_token.type = Token::Type::IF
        else
          consume_identifier
        end
      when 'u'
        if read_char == 'n'
          read_char
          puts current_char
          case current_char
          when 'l'
            if read_char == 'e' && read_char == 's' && read_char == 's'
              read_char
              @current_token.type = Token::Type::UNLESS
            else
              consume_identifier
            end
          when 't'
            if read_char == 'i' && read_char == 'l'
              read_char
              @current_token.type = Token::Type::UNTIL
            else
              consume_identifier
            end
          else
            consume_identifier
          end
        else
          consume_identifier
        end
      when 't'
        if read_char == 'r' && read_char == 'u' && read_char == 'e'
          read_char
          @current_token.type = Token::Type::TRUE
        else
          consume_identifier
        end
      when 'w'
        if read_char == 'h' && read_char == 'i' && read_char == 'l' && read_char == 'e'
          read_char
          @current_token.type = Token::Type::WHILE
        else
          consume_identifier
        end
      when .ascii_number?
        consume_numeric
      when .ascii_whitespace?
        consume_whitespace
      # Everything else should be tried as an identifier
      else
        consume_identifier
      end

      @current_token.raw = @reader.buffer_value
      @current_token.location.length = @current_token.raw.size

      @reader.buffer.clear
      @reader.buffer << current_char

      @tokens << @current_token
      @current_token
    end


    def consume_numeric
      has_decimal = false

      loop do
        case current_char
        when '.'
          read_char

          if has_decimal
            raise SyntaxError.new(Location.new, "Unexpected second decimal in `#{@reader.buffer_value}`")
          else
            has_decimal = true
          end
        when '_'
          read_char

          if has_decimal
            raise SyntaxError.new(Location.new, "Unexecpted underscore after decimal point in `#{@reader.buffer_value}`")
          end
        when .ascii_number?
          read_char
        else
          break
        end
      end

      @current_token.value = @reader.buffer_value.tr("_", "")
      @current_token.type = has_decimal ? Token::Type::FLOAT : Token::Type::INTEGER
    end

    def consume_string
      # Read the starting quote character
      read_char

      loop do
        case current_char
        when '"'
          # Read the closing quote, then stop
          read_char
          break
        when '\\'
          # Read two characters to naively support escaped characters.
          read_char
          read_char
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
        end
      end
      # Strip the containing quote characters
      @current_token.value = @current_token.value[1..-2]
    end

    def consume_whitespace
      @current_token.type = Token::Type::WHITESPACE

      while read_char.ascii_whitespace?; end
    end

    def consume_identifier
      # Identifiers must start with a letter or an underscore
      unless current_char.ascii_letter? || current_char == '_'
        raise SyntaxError.new(Location.new, "Unexpected character `#{current_char}`. Current buffer: `#{@reader.buffer_value}`.")
      end

      loop do
        if current_char.ascii_alphanumeric? || current_char == '_'
          read_char
        else
          break
        end
      end

      @current_token.type = Token::Type::IDENT
      @current_token.value = @reader.buffer_value
    end
  end
end
