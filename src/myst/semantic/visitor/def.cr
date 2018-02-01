module Myst
  module Semantic
    class Visitor
      def visit(node : Def)
        DuplicateParamNamesAssertion.new(owner: node, params: node.params).run
      end
    end
  end
end
