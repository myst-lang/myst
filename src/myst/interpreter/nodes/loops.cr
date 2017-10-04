module Myst
  class Interpreter
    def visit(node : While)
      while true
        visit(node.condition)
        condition = stack.pop

        if condition.truthy?
          visit(node.body)
          stack.pop
        else
          break
        end
      end

      stack.push(TNil.new)
    end

    def visit(node : Until)
      until true
        visit(node.condition)
        condition = stack.pop

        unless condition.truthy?
          visit(node.body)
          stack.pop
        else
          break
        end
      end

      stack.push(TNil.new)
    end
  end
end
