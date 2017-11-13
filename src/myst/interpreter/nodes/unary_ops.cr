module Myst
  class Interpreter

    def visit(node : Negation)
      # Default case for Myst::IntegerLiteral
      null = val(0)

      # This block is used to avoid a cast error to TInteger to TFloat when
      # calling :float_subtract
      if  node.value.class == Myst::FloatLiteral
        null = val(0.0)
      end

      v = Value.from_literal(node.value)
      substract = self.__scopeof(v)["-"].as(TFunctor)
      result = Invocation.new(self, substract, null, [v] , nil).invoke
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
