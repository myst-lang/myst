module Myst
  class Interpreter

    def visit(node : Negation)
      v = Value.from_literal(node.value)
      func = self.__scopeof(v)["-"].as(TFunctor)
      result = Invocation.new(self, func, val(0), [v] , nil).invoke
      stack.push(result)
    end
  end
end
