module Myst
  class Interpreter
    def visit(node : Negation)
      visit(node.value)
      value = stack.pop()
      negate = recursive_lookup(value, "negate").as(TFunctor)
      result = Invocation.new(self, negate, value, [] of MTValue, nil).invoke
      stack.push(result)
    end

    def visit(node : Not)
      visit(node.value)
      value = stack.pop()

      result =
        if not_method = self.recursive_lookup(value, "!")
          not_method = not_method.as(TFunctor)
          Invocation.new(self, not_method, value, [] of MTValue , nil).invoke
        else
          !value.truthy?
        end

      stack.push(result)
    end

    def visit(node : Splat)
      visit(node.value)
      value = stack.pop

      if splat_method = recursive_lookup(value, "*").as?(TFunctor)
        splat_method = splat_method.as(TFunctor)
        result = Invocation.new(self, splat_method, value, [] of MTValue, nil).invoke
      else
        __raise_not_found("* (splat)", value)
      end

      # The result of a Splat operation is always expected to be a List
      unless result.is_a?(TList)
        __raise_runtime_error("Expected a List value from splat")
      end

      stack.push(result)
    end
  end
end
