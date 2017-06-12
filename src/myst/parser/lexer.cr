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
      when '('
        @current_token.type = Token::Type::LPAREN
        read_char
      when ')'
        @current_token.type = Token::Type::RPAREN
        read_char
      when .ascii_number?
        consume_numeric
      when .ascii_whitespace?
        consume_whitespace
      # When a token isn't matched, raise an error
      else
        raise SyntaxError.new(Location.new, "Unexpected character `#{current_char}`. Current buffer: `#{@reader.buffer_value}`.")
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
      @current_token.type
    end

    def consume_whitespace
      @current_token.type = Token::Type::WHITESPACE

      while read_char.ascii_whitespace?; end
    end
  end
end
