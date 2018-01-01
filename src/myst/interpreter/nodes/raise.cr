module Myst
  class Interpreter
    def visit(node : Raise)
      visit(node.value)
      value = stack.pop

      __raise_runtime_error(value)
    end
  end
end
