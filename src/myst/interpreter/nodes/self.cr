module Myst
  class Interpreter
    def visit(node : Self)
      stack.push(current_self)
    end
  end
end
