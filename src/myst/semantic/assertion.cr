module Myst
  module Semantic
    abstract class Assertion
      abstract def run

      # Raise a Semantic::Error with the given message.
      def fail!(location : Location, message : String)
        raise Error.new(location, message)
      end
    end
  end
end
