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
      v = Value.from_literal(node.value)
      if v.to_s == "true"
        stack.push(TBoolean.new(false))
      else
        stack.push(TBoolean.new(true))
      end
    end

  end
end
