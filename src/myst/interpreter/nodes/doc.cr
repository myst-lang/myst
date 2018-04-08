module Myst
  class Interpreter
    def visit(node : DocComment)
      node.target.accept(self)

      # The target is left on the stack so that the comment node can act
      # transparently to the rest of the program.
      target = @stack.last
      @doc_table[target] = node
    end
  end
end
