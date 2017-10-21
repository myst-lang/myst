module Myst
  class Interpreter
    def visit(node : ExceptionHandler)
      stack_size_at_entry = stack.size

      begin
        visit(node.body)
      rescue err : RuntimeError
        # Before rescuing, restore the stack to its state from before
        # executing the body.
        handled = false
        node.rescues.each do |resc|
          self.push_scope_override
          if !resc.param? || rescue_matches?(resc.param, err.value)
            visit(resc.body)
            self.pop_scope_override
            handled = true
            break
          else
            self.pop_scope_override
          end
        end

        raise err unless handled
      end

      if node.ensure?
        visit(node.ensure)
        # Ensure should not change the result of the expression, so its value
        # is immediately popped.
        stack.pop
      end
    end

    private def rescue_matches?(param : Param, arg : Value)
      self.match(param.pattern, arg)        if param.pattern?
      self.match(Var.new(param.name), arg)  if param.name?
      # `match` will raise a MatchError if the match was not successful.
      # Getting to this point means the match was successful.
      return true
    rescue MatchError
      return false
    end
  end
end
