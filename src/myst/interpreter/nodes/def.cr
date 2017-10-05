module Myst
  class Interpreter
    def visit(node : Def)
      # If a functor with the same name already exists in the current scope,
      # use it. Otherwise, create a new functor in the current scope.
      if @symbol_table.has_key?(node.name)
        functor = @symbol_table[node.name].as(TFunctor)
      else
        functor = TFunctor.new([] of Callable, current_scope)
        @symbol_table.assign(node.name, functor)
      end

      functor.add_clause(TFunctorDef.new(node))
      @stack.push(functor)
    end
  end
end
