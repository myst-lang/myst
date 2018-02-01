require "./visitor/*"

module Myst
  module Semantic
    class Visitor
      property  output : IO
      property  errput : IO
      property? capture_failures : Bool

      def initialize(@output : IO = STDOUT, @errput : IO = STDERR, @capture_failures=false)
      end

      def visit(node : Node)
        # Not all nodes need semantic analysis beyond what the parser provides.
        # To ensure that all nodes are visited, though, the default behavior
        # is to call `accept_children` on the node, which will recurse the
        # visitor through any node properties of the current node.
        node.accept_children(self)
      end
    end
  end
end
