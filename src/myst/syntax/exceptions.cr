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
    property expected : Token::Type | Array(Token::Type) | String | Nil

    def initialize(@got, @expected=nil)
      @message =  case @expected
                  when String
                    "#{@expected}, got #{@got.type} instead (at #{@got.location})"
                  when Token::Type | Array(Token::Type)
                    "Expected #{@expected}, got #{@got.type} instead (at #{@got.location})"
                  else
                    "Unexpected token `#{@got.type}` (at #{@got.location})"
                  end
    end
  end
end
