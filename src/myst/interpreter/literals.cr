module Myst
  class Interpreter
    def visit(node : ListLiteral)
    end

    def visit(node : MapLiteral)
    end

    def visit(node : Literal)
      stack.push(Value.from_literal(node))
    end
  end
end
