require "./location"

module Myst
  class Token
    enum Type
      INTEGER     # [0-9]+
      FLOAT       # [0-9][_0-9]*\.[0-9]+
      STRING      # "hello"
      CHAR        # 'c'

      KEYWORD     # if, else, while, def,...
      IDENT       # [a-zA-Z][_a-zA-Z0-9]*

      PLUS        # +
      MINUS       # -
      STAR        # *
      SLASH       # /

      EQUAL       # =

      LPAREN      # (
      RPAREN      # )
      LBRACE      # [
      RBRACE      # ]
      LCURLY      # {
      RCURLY      # }

      NEWLINE     # \n
      WHITESPACE  # space, tab, etc.
      EOF         # End of File
      UNKNOWN     # Unresolved type

      def unary_operator?
        self == PLUS || self == MINUS
      end

      def binary_operator?
        self == PLUS || self == MINUS || self == STAR || self == SLASH
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
