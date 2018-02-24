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
      if (ivar = current_self.ivars[node.name]?).nil?
        ivar = current_self.ivars.assign(node.name, TNil.new)
      end

      stack.push(ivar)
    end

    def visit(node : Const)
      value = current_scope[node.name]?
      if value.nil?
        value = __typeof(current_self).scope[node.name]?
      end
      if value.nil?
        value = recursive_lookup(current_self, node.name)
      end
      if !value.nil?
        stack.push(value)
      else
        __raise_not_found(node.name, current_self)
      end
    end

    def visit(node : Underscore)
      warn("Reference to an underscore value `#{node.name}`\n" +
           "Underscores indicate that a variable should not be referenced.\n" +
           "If this reference is intentional, consider removing the " +
           "leading `_`.", node)
      stack.push(lookup(node))
    end
  end
end
