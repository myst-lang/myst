module Myst
  class Interpreter
    def visit(node : ModuleDef)
      # If a module with the same name already exists in the current scope,
      # use it. Otherwise, create a new module in the current scope.
      if current_scope.has_key?(node.name)
        _module = current_scope[node.name].as(TModule)
      else
        _module = TModule.new(node.name, current_scope)
        current_scope.assign(node.name, _module)
      end

      push_self(_module)
      visit(node.body)
      pop_self

      # Evaluating the body of the module will leave the last expression
      # evaluated on the stack, but the return value of a ModuleDef is the
      # module itself. So, the old value is popped and the new value is put in
      # its place.
      @stack.pop
      @stack.push(_module)
    end
  end
end
