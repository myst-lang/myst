module Myst
  class Interpreter
    def visit(node : MatchAssign)
      node.value.accept(self)
      # The result of the assignment should be the value that is assigned, so
      # it can be left on the stack.
      value = stack.last
      match(node.pattern, value)
    end
  end
end
