module Myst
  class Interpreter
    def visit(node : ExceptionHandler)
      selfstack_size_at_entry = self_stack.size
      scopestack_size_at_entry = @scope_stack.size

      begin
        visit(node.body)
      rescue err : RuntimeError
        # Before rescuing, restore the stack to its state from before
        # executing the body.
        pop_self(to_size: selfstack_size_at_entry)

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
      ensure
        self.pop_scope_override(to_size: scopestack_size_at_entry)

        if node.ensure?
          # Ensure should not change the result of the expression, so its
          # value is immediately popped.
          visit(node.ensure)
          stack.pop
        end
      end
    end

    private def rescue_matches?(param : Param, arg : Value)
      self.match(param.pattern, arg)        if param.pattern?
      self.match(Var.new(param.name), arg)  if param.name?
      self.match(param.restriction, arg)    if param.restriction?
      # `match` will raise a MatchError if the match was not successful.
      # Getting to this point means the match was successful.
      return true
    rescue MatchError
      return false
    end
  end
end
