require "./location"

module Myst
  class BaseException < Exception
  end

  class SyntaxError < BaseException
    property location : Location

    def initialize(@location, @message="")
      @message = "Syntax error at #{@location}: #{@message}"
    end
  end

  class ParseError < BaseException
    property got : Token
    property expected : Token::Type | Array(Token::Type) | Nil

    def initialize(@got, @expected=nil)
      @message = if @expected
        "Expected one of #{@expected}, got #{@got.type} instead (at #{@got.location})"
      else
        "Unexpected token `#{@got.type}` (at #{@got.location})"
      end
    end
  end
end
