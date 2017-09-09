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
  end
end
