module Myst
  class Interpreter
    def visit(node : Var)
      stack.push(current_scope[node.name])
    end

    def visit(node : IVar)
      # IVars always operate on the current value of `self`, rather than just
      # the current scope. This allows them to be used across functions.
      #
      # If an instance variable has not yet been defined on the object, a
      # reference to it will initialize it to `nil`.
      unless ivar = current_self.ivars[node.name]?
        ivar = current_self.ivars.assign(node.name, TNil.new)
      end

      stack.push(ivar)
    end

    def visit(node : Const)
      stack.push(current_scope[node.name])
    end

    def visit(node : Underscore)
      stack.push(current_scope[node.name])
    end
  end
end
