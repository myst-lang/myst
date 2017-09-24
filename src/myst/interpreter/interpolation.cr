module Myst
  class Interpreter
    def visit(node : ValueInterpolation)
      # Interpolations are essentially pass-throughs for immediately
      # evaluating a node.
      # In patterns, function parameters, and Map keys, interpolations allow
      # arbitrary expressions to be evaluated and the result to be used in the
      # place that the interpolation occurs.
      # In all other cases, an interpolation serves no purpose and should not
      # be used (the expression itself is sufficient).
      node.value.accept(self)
    end
  end
end
