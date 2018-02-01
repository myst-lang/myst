module Myst
  module Semantic
    abstract class Assertion
      abstract def message : String

      abstract def run
    end
  end
end
