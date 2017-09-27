module Myst
  class Interpreter
    def visit(node : Expressions)
      node.children.each_with_index do |expr, idx|
        expr.accept(self)
        # Unless this is the last expression in the block, pop the result of
        # the current expression from the stack (by this point, any use of
        # the value will have happened, and it can now be discarded).
        @stack.pop if idx < node.children.size - 1
      end
    end
  end
end
