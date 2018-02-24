module Myst
  class Interpreter
    def visit(node : ExceptionHandler)
      selfstack_size_at_entry = self_stack.size
      scopestack_size_at_entry = @scope_stack.size
      callstack_size_at_entry = @callstack.size

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
            @callstack.push(resc.location, "rescue")
            visit(resc.body)
            self.pop_scope_override
            handled = true
            break
          else
            self.pop_scope_override
          end
        end

        if handled
          self.pop_callstack(to_size: callstack_size_at_entry)
        else
          raise err
        end
      ensure
        # `pop_callstack` is purposefully not done in this `ensure` block to
        # avoid popping `raise` and `rescue` entries that have not yet been
        # handled.
        self.pop_self(to_size: selfstack_size_at_entry)
        self.pop_scope_override(to_size: scopestack_size_at_entry)

        if node.ensure?
          @callstack.push(node.ensure.location, "ensure")
          # Ensure should not change the result of the expression, so its
          # value is immediately popped.
          visit(node.ensure)
          stack.pop
        end
      end
    end

    private def rescue_matches?(param : Param, arg : MTValue)
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
