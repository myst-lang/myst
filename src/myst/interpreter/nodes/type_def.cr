module Myst
  class Interpreter
    def visit(node : TypeDef)
      # If a type with the same name already exists in the current scope,
      # use it. Otherwise, create a new type in the current scope.
      if current_scope.has_key?(node.name)
        type = current_scope[node.name].as(TType)
      else
        type = TType.new(node.name, current_scope)
        current_scope.assign(node.name, type)
      end

      push_self(type)
      visit(node.body)
      pop_self


      # Evaluating the body of the module will leave the last expression
      # evaluated on the stack, but the return value of a ModuleDef is the
      # module itself. So, the old value is popped and the new value is put in
      # its place.
      @stack.pop
      @stack.push(type)
    end
  end
end
