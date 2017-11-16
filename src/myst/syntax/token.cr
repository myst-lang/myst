require "./location"

module Myst
  class Token
    enum Type
      INTEGER       # [0-9]+
      FLOAT         # [0-9][_0-9]*\.[0-9]+
      STRING        # "hello"
      CHAR          # 'c'
      SYMBOL        # :symbol

      # INTERP_* tokens will only appear within a string.
      INTERP_START  # <(
      INTERP_END    # )>

      REQUIRE       # require
      INCLUDE       # include
      DEFMODULE     # defmodule
      DEFTYPE       # deftype
      DEF           # def
      DEFSTATIC     # defstatic
      FN            # fn
      DO            # do
      UNLESS        # unless
      ELSE          # else
      WHILE         # while
      UNTIL         # until
      WHEN          # when
      END           # end
      RETURN        # return
      BREAK         # break
      NEXT          # next
      RAISE         # raise
      RESCUE        # rescue
      ENSURE        # ensure

      SELF          # self

      TRUE          # true
      FALSE         # false
      NIL           # nil
      IDENT         # [a-z][_a-zA-Z0-9]*
      CONST         # [A-Z][a-zA-Z0-9]*
      IVAR          # @[a-z][_a-zA-Z0-9]*
      MAGIC_CONST   # __[A-Z][_A-Z]*__

      PLUS          # +
      MINUS         # -
      STAR          # *
      SLASH         # /
      MODULO        # %

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

      ANDOP         # &&=
      OROP          # ||=
      PLUSOP        #  +=
      MINUSOP       #  -=
      STAROP        #  *=
      SLASHOP       #  /=
      MODOP         #  %=

      AMPERSAND     # &
      PIPE          # |

      LPAREN        # (
      RPAREN        # )
      LBRACE        # [
      RBRACE        # ]
      LCURLY        # {
      RCURLY        # }

      STAB          # ->

      COMMA         # ,
      POINT         # .
      COLON         # :
      SEMI          # ;

      COMMENT       # # comment
      NEWLINE       # \n
      WHITESPACE    # space, tab, etc.
      EOF           # End of File
      UNKNOWN       # Unresolved type


      def self.whitespace
        [ COMMENT, WHITESPACE, UNKNOWN ]
      end

      def whitespace?
        self.whitespace.includes?(self)
      end

      def self.keywords
        [ REQUIRE, INCLUDE,
          DEFMODULE, DEFTYPE, DEF, DEFSTATIC, FN, DO, END,
          WHEN, UNLESS, ELSE,
          WHILE, UNTIL,
          TRUE, FALSE, NIL,
          RETURN, BREAK, NEXT,
          RAISE, RESCUE, ENSURE,
          SELF
        ]
      end


      def self.keyword_map
        {
          "require" => REQUIRE,
          "include" => INCLUDE,
          "defmodule" => DEFMODULE,
          "deftype" => DEFTYPE,
          "def" => DEF,
          "defstatic" => DEFSTATIC,
          "fn" => FN,
          "do" => DO,
          "end" => END,
          "when" => WHEN,
          "unless" => UNLESS,
          "else" => ELSE,
          "while" => WHILE,
          "until" => UNTIL,
          "true" => TRUE,
          "false" => FALSE,
          "nil" => NIL,
          "return" => RETURN,
          "break" => BREAK,
          "next" => NEXT,
          "raise" => RAISE,
          "rescue" => RESCUE,
          "ensure" => ENSURE,
          "self" => SELF
        }
      end

      def keyword?
        self.class.keywords.includes?(self)
      end

      def block_terminator?
        self == END
      end

      def self.delimiters
        [NEWLINE, SEMI, EOF]
      end

      def delimiter?
        self.class.delimiters.includes?(self)
      end

      def self.op_assigns
        [ANDOP, OROP, PLUSOP, MINUSOP, STAROP, SLASHOP, MODOP]
      end

      def op_assign?
        self.class.op_assigns.includes?(self)
      end


      def self.unary_operators
        [PLUS, MINUS, NOT, STAR, AMPERSAND]
      end

      def self.binary_operators
        [ PLUS, MINUS, STAR, SLASH, MODULO, EQUAL, MATCH, LESS, LESSEQUAL,
          GREATEREQUAL, GREATER, NOTEQUAL, EQUALEQUAL, ANDAND, OROR]
      end

      def self.overloadable_operators
        [ PLUS, MINUS, STAR, SLASH, MODULO, MATCH, LESS, LESSEQUAL,
          NOTEQUAL, EQUALEQUAL, GREATEREQUAL, GREATER]
      end

      def unary_operator?
        self.class.unary_operators.includes?(self)
      end

      def binary_operator?
        self.class.binary_operators.includes?(self)
      end

      def overloadable_operator?
        self.class.overloadable_operators.includes?(self)
      end

      def operator?
        unary_operator? || binary_operator?
      end
    end


    property type     : Type
    property value    : String?
    property raw      : String
    property location : Location


    def initialize(@type=Type::UNKNOWN, @value=nil, @raw="", *, @location)
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
