module Myst
  class Interpreter
    def visit(node : Def)
      scope =
        case {type = current_self, node.static?}
        when {TType, true}
          type.scope
        when {TType, false}
          type.instance_scope
        when {Value, true}
          # Any other kind of value is not allowed to define static methods.
          raise "Cannot define static method on #{current_self.type.name}"
        else
          current_scope
        end

      # If a functor with the same name already exists in the current scope,
      # use it. Otherwise, create a new functor in the current scope.
      if scope.has_key?(node.name)
        functor = scope[node.name].as(TFunctor)
      else
        functor = TFunctor.new([] of Callable, scope)
        scope.assign(node.name, functor)
      end

      functor.add_clause(TFunctorDef.new(node))
      @stack.push(functor)
    end
  end
end
