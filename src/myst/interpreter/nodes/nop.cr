module Myst
  class Interpreter
    def visit(node : Nop)
      stack.push(TNil.new)
    end
  end
end
