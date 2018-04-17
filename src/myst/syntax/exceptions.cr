require "./location"

module Myst
  class BaseException < Exception
    property location : Location

    def initialize(@location, @message="")
      # We're showing a custom message. The implementation backtrace is just
      # noise to end users.
      @callstack = nil
    end

    def inspect_with_backtrace(io : IO)
      io << message
    end
  end

  class SyntaxError < BaseException
    def initialize(@location, @message="")
      super(@location, "Syntax error at #{@location}: #{@message}")
    end
  end

  class ParseError < BaseException
    def initialize(@location, @message="")
      super(@location,
        <<-MESSAGE
        ParseError at #{@location}
          #{@message}

        MESSAGE
      )
    end
  end
end
