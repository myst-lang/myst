module Myst
  module Semantic
    class Visitor
      def visit(node : Def)
        ParamNamesAssertion.new(owner: node, params: node.params).run
      end
    end
  end
end
