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
    property got : Token::Type
    property expected : Token::Type?

    def initialize(@got, @expected=nil)
      @message = if @expected
        "Expected token `#{@expected}`, got #{@got} instead."
      else
        "Unexpected token `#{@got}`."
      end
    end
  end

  class RuntimeError < BaseException
  end
end
