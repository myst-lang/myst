module Myst
  class Interpreter
    def visit(node : Negation)
      visit(node.value)
      value = stack.pop()
      negate = self.__scopeof(value)["negate"].as(TFunctor)
      result = Invocation.new(self, negate, value, [] of Value, nil).invoke
      stack.push(result)
    end

    def visit(node : Not)
      visit(node.value)
      value = stack.pop()

      result =
        if not_method = self.__scopeof(value)["!"]?
          not_method = not_method.as(TFunctor)
          Invocation.new(self, not_method, value, [] of Value , nil).invoke
        else
          TBoolean.new(!value.truthy?)
        end

      stack.push(result)
    end

    def visit(node : Splat)
      visit(node.value)
      value = stack.pop

      if splat_method = recursive_lookup(value, "*").as?(TFunctor)
        splat_method = splat_method.as(TFunctor)
        result = Invocation.new(self, splat_method, value, [] of Value, nil).invoke
      else
        raise_not_found("* (splat)", value)
      end

      # The result of a Splat operation is always expected to be a List
      unless result.is_a?(TList)
        raise RuntimeError.new(TString.new("Expected a List value from splat"), callstack)
      end

      stack.push(result)
    end
  end
end
