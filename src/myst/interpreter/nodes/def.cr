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
          raise "Cannot define static method on #{__typeof(current_self).name}"
        else
          current_scope
        end

      # Blocks are _anonymous_ Defs, meaning they should never be assigned in
      # to a scope. In other words, every Block should be considered its own
      # Functor.
      unless node.is_a?(Block)
        # If a functor with the same name already exists in the current scope,
        # use it. Otherwise, create a new functor in the current scope.
        if scope.has_key?(node.name)
          functor = scope[node.name].as(TFunctor)
        else
          functor = TFunctor.new([] of Callable, scope, closure: false)
          scope.assign(node.name, functor)
        end
      else
        functor = TFunctor.new([] of Callable, scope, closure: true)
      end

      functor.add_clause(TFunctorDef.new(node))
      @stack.push(functor)
    end
  end
end
