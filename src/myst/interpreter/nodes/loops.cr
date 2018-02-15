module Myst
  class Interpreter
    def visit(node : While)
      do_loop_expression(node, inverted: false)
    end

    def visit(node : Until)
      do_loop_expression(node, inverted: true)
    end

    private def do_loop_expression(node : Node, inverted : Bool)
      while true
        visit(node.condition)
        condition = stack.pop

        if (inverted ? !condition.truthy? : condition.truthy?)
          visit(node.body)
          stack.pop
        else
          break
        end
      end

      stack.push(TNil.new)
    rescue ex : BreakException
      # If a `break` appears within a loop expression, it will cause the loop to
      # immediately terminate. Unlike `break` within a block, however, it will
      # not propogate beyond the loop.
      #
      # The `Break` node that caused the `BreakException` being caught here will
      # have already pushed the appropriate value onto the stack, so no extra
      # work needs to be done here.
    end
  end
end
