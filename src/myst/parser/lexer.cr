require "./token"
require "./exceptions"
require "./reader"

module Myst
  class Lexer
    # Source code being lexed.
    property reader : Reader
    # Full path to the source file used by this lexer. For STDIN and other
    # non-local input methods, this will be `nil`.
    property source_file : String?
    # Full path to the directory of the source. For STDIN and other non-local
    # input methods, this will be the value of `pwd` where program Myst was
    # run.
    property working_dir : String

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



    def initialize(source : IO, source_file : String? = nil)
      @reader = Reader.new(source)
      @source_file = source_file
      @working_dir = source_file ? File.dirname(source_file) : `pwd`

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
      @current_token.location.file  = @source_file
      @current_token.location.line  = @row
      @current_token.location.col   = @col
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
      when '#'
        @current_token.type = Token::Type::COMMENT
        consume_comment
      when '"'
        @current_token.type = Token::Type::STRING
        consume_string
      when ':'
        consume_symbol_or_colon
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
      else
        # Everything else should be tried as either a keyword or an identifier.
        # First, attempt to lex an identifier, then check if the identifier as
        # a whole constitutes a keyword. This should prevent misclassifications
        # for sequences like `definition` and `required` that would otherwise
        # be considered a keyword followed by an identifier.
        consume_identifier
        check_for_keyword
      end

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
          read_char

          if has_decimal
            raise SyntaxError.new(current_location, "Unexpected second decimal in `#{@reader.buffer_value}`")
          else
            has_decimal = true
          end
        when '_'
          read_char

          if has_decimal
            raise SyntaxError.new(current_location, "Unexecpted underscore after decimal point in `#{@reader.buffer_value}`")
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

    def consume_symbol_or_colon
      # Read the starting colon
      read_char
      case current_char
      when '"'
        # Quoted values allow for arbitrary symbol names
        consume_string
      when .ascii_whitespace?
      else
        consume_identifier
      end

      if @current_token.value.size > 1
        @current_token.type = Token::Type::SYMBOL
        @current_token.value = @current_token.value[1..-1]
      else
        @current_token.type = Token::Type::COLON
      end
    end

    def consume_comment
      until read_char == '\n'; end
    end

    def consume_whitespace
      @current_token.type = Token::Type::WHITESPACE

      while read_char.ascii_whitespace?; end
    end

    def consume_identifier
      # Identifiers must start with a letter or an underscore
      unless current_char.ascii_letter? || current_char == '_'
        raise SyntaxError.new(current_location, "Unexpected character `#{current_char}`. Current buffer: `#{@reader.buffer_value}`.")
      end

      loop do
        if current_char.ascii_alphanumeric? || current_char == '_'
          read_char
        else
          break
        end
      end

      @current_token.value = @reader.buffer_value
    end
  end
end
