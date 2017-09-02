require "./location"

module Myst
  class Token
    enum Type
      INTEGER       # [0-9]+
      FLOAT         # [0-9][_0-9]*\.[0-9]+
      STRING        # "hello"
      CHAR          # 'c'
      SYMBOL        # :symbol

      REQUIRE       # require
      INCLUDE       # include
      MODULE        # module
      DEF           # def
      DO            # do
      UNLESS        # unless
      ELSE          # else
      WHILE         # while
      UNTIL         # until
      WHEN          # when
      END           # end

      TRUE          # true
      FALSE         # false
      NIL           # nil
      IDENT         # [a-z][_a-zA-Z0-9]*
      CONST         # [A-Z][a-zA-Z0-9]*

      PLUS          # +
      MINUS         # -
      STAR          # *
      SLASH         # /

      EQUAL         # =
      MATCH         # =:
      NOT           # !
      LESS          # <
      LESSEQUAL     # <=
      GREATEREQUAL  # >=
      GREATER       # >

      NOTEQUAL      # !=
      EQUALEQUAL    # ==

      ANDAND        # &&
      OROR          # ||

      AMPERSAND     # &
      PIPE          # |

      LPAREN        # (
      RPAREN        # )
      LBRACE        # [
      RBRACE        # ]
      LCURLY        # {
      RCURLY        # }

      COMMA         # ,
      POINT         # .
      COLON         # :

      COMMENT       # # comment
      NEWLINE       # \n
      WHITESPACE    # space, tab, etc.
      EOF           # End of File
      UNKNOWN       # Unresolved type


      def self.keywords
        [REQUIRE, INCLUDE, MODULE, DEF, DO, UNLESS, ELSE, END, WHILE, UNTIL, WHEN, TRUE, FALSE, NIL]
      end


      def self.keyword_map
        {
          "require" => REQUIRE,
          "include" => INCLUDE,
          "module" => MODULE,
          "def" => DEF,
          "do" => DO,
          "unless" => UNLESS,
          "else" => ELSE,
          "end" => END,
          "while" => WHILE,
          "until" => UNTIL,
          "when" => WHEN,
          "true" => TRUE,
          "false" => FALSE,
          "nil" => NIL
        }
      end

      def keyword?
        self.class.keywords.includes?(self)
      end

      def block_terminator?
        self == END
      end


      def self.unary_operators
        [PLUS, MINUS, NOT, STAR, AMPERSAND]
      end

      def self.binary_operators
        [ PLUS, MINUS, STAR, SLASH, EQUAL, MATCH, LESS, LESSEQUAL,
          GREATEREQUAL, GREATER, NOTEQUAL, EQUALEQUAL, ANDAND, OROR]
      end

      def unary_operator?
        self.class.unary_operators.includes?(self)
      end

      def binary_operator?
        self.class.binary_operators.includes?(self)
      end

      def operator?
        unary_operator? || binary_operator?
      end
    end


    property type     : Type
    property value    : String?
    property raw      : String
    property location : Location


    def initialize(@type=Type::UNKNOWN, @value=nil, @raw="", @location=Location.new)
    end


    # Avoid having to explicitly set `value`.
    def value
      @value || raw
    end

    def to_s
      value
    end

    def to_s(io)
      io << to_s
    end

    def inspect(io)
      io << "#{@type}:#{raw}"
    end
  end
end
