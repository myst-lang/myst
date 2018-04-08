module Myst
  class Interpreter
    def visit(node : TypeDef)
      # If a type with the same name already exists in the current scope,
      # use it. Otherwise, create a new type in the current scope.
      if current_scope.has_key?(node.name)
        type = current_scope[node.name].as(TType)
        if node.supertype?
          __raise_runtime_error("Specifying a supertype when re-opening an existing type is not allowed.")
        end
      else
        supertype =
          if node.supertype?
            visit(node.supertype)
            typ = stack.pop
            unless typ.is_a?(TType)
              __raise_runtime_error("Supertype of #{node.name} must be a Type object, but resolved to a #{typ.type_name}")
            end
            typ
          else
            @base_type
          end

        type = __make_type(node.name, current_scope, supertype)
        current_scope.assign(node.name, type)
      end

      push_self(type)
      @doc_stack.push(node.name)
      visit(node.body)
      @doc_stack.pop
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
