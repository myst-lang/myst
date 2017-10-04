module Myst
  class Interpreter
    def visit(node : When)
      visit(node.condition)
      condition = stack.pop

      if condition.truthy?
        visit(node.body)
      else
        visit(node.alternative)
      end
    end

    def visit(node : Unless)
      visit(node.condition)
      condition = stack.pop

      unless condition.truthy?
        visit(node.body)
      else
        visit(node.alternative)
      end
    end
  end
end
