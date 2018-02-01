module Myst
  module Semantic
    class Error < Exception
      property location : Location

      def initialize(@location : Location, @message : String)
      end

      def message
        <<-MESSAGE
        Semantic Error at #{@location}:

        #{@message}
        MESSAGE
      end
    end
  end
end
