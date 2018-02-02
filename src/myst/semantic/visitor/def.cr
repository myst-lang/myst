module Myst
  module Semantic
    class Visitor
      def visit(node : Def)
        DuplicateParamNamesAssertion.new(node).run
      end
    end
  end
end
