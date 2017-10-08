module Myst
  class Interpreter
    def visit(node : Def)
      # If a functor with the same name already exists in the current scope,
      # use it. Otherwise, create a new functor in the current scope.
      if current_scope.has_key?(node.name)
        functor = current_scope[node.name].as(TFunctor)
      else
        functor = TFunctor.new([] of Callable, current_scope)
        current_scope.assign(node.name, functor)
      end

      functor.add_clause(TFunctorDef.new(node))
      @stack.push(functor)
    end
  end
end
