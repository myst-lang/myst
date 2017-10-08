module Myst
  class Interpreter
    def visit(node : ModuleDef)
      # If a module with the same name already exists in the current scope,
      # use it. Otherwise, create a new module in the current scope.
      if @symbol_table.has_key?(node.name)
        _module = @symbol_table[node.name].as(TModule)
      else
        _module = TModule.new(current_scope)
        @symbol_table.assign(node.name, _module)
      end

      push_scope(_module.scope)
      visit(node.body)
      pop_scope

      # Evaluating the body of the module will leave the last expression
      # evaluated on the stack, but the return value of a ModuleDef is the
      # module itself. So, the old value is popped and the new value is put in
      # its place.
      @stack.pop
      @stack.push(_module)
    end
  end
end
