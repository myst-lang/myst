require "../exceptions.cr"

module Myst
  class Interpreter
    def visit(node : Return)
      if node.value?
        visit(node.value)
      else
        stack.push(TNil.new)
      end

      raise ReturnException.new
    end
  end
end
