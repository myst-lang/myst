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
        if not_method = self.__scopeof(value)["not"]?
          not_method = not_method.as(TFunctor)
          Invocation.new(self, not_method, value, [] of Value , nil).invoke
        else
          TBoolean.new(!value.truthy?)
        end

      stack.push(result)
    end

  end
end
