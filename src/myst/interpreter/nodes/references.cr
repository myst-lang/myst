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
  end
end
