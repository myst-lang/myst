module Myst
  class Interpreter
    def visit(node : Var)
      stack.push(lookup(node))
    end

    def visit(node : IVar)
      # IVars always operate on the current value of `self`, rather than just
      # the current scope. This allows them to be used across functions.
      #
      # If an instance variable has not yet been defined on the object, a
      # reference to it will initialize it to `nil`. Because of that, a
      # reference to an instance variable will never fail to lookup (even when
      # spelled incorrectly).
      unless ivar = current_self.ivars[node.name]?
        ivar = current_self.ivars.assign(node.name, TNil.new)
      end

      stack.push(ivar)
    end

    def visit(node : Const)
      stack.push(lookup(node))
    end

    def visit(node : Underscore)
      stack.push(lookup(node))
    end


    private def lookup(node)
      if value = current_scope[node.name]?
        value
      else
        @callstack.push(node)
        raise_not_found(node.name, current_self)
      end
    end

    private def raise_not_found(name, value)
      type_name = __typeof(value).name
      error_message = "No variable or method `#{name}` for #{type_name}"

      if value_to_s = __scopeof(value)["to_s"]?
        value_to_s = value_to_s.as(TFunctor)
        value_str = Invocation.new(self, value_to_s, value, [] of Value, nil).invoke
        error_message = "No variable or method `#{name}` for #{value_str}:#{type_name}"
      end

      raise RuntimeError.new(TString.new(error_message), callstack)
    end
  end
end
