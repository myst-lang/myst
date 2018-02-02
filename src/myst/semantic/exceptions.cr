module Myst
  module Semantic
    class Error < Exception
      property location : Location

      def initialize(@location : Location, @message : String)
        @callstack = nil
      end

      def message
        <<-MESSAGE

        Semantic Error at #{@location}:

        #{@message}


        MESSAGE
      end

      def inspect_with_backtrace(io : IO)
        io << message
      end
    end
  end
end
