module Myst
  class Interpreter
    def visit(node : Def)
      # If a functor with the same name already exists in the current scope,
      # use it. Otherwise, create a new functor in the current scope.
      functor =
        if @symbol_table.has_key?(node.name)
          @symbol_table[node.name].as(TFunctor)
        else
          @symbol_table.assign(node.name, TFunctor.new(current_scope))
        end

      functor.add_clause(node)
      @stack.push(functor)
    end
  end
end
