module Myst
  module Semantic
    abstract class Assertion
      abstract def run

      # Raise a Semantic::Error with the given message.
      def fail!(message : String)
        raise Error.new(message)
      end
    end
  end
end
