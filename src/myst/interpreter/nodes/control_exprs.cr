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

    def visit(node : Break)
      if node.value?
        visit(node.value)
      else
        stack.push(TNil.new)
      end

      raise BreakException.new
    end

    def visit(node : Next)
      if node.value?
        visit(node.value)
      else
        stack.push(TNil.new)
      end

      raise NextException.new
    end
  end
end
