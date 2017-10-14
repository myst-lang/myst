module Myst
  class Interpreter
    def visit(node : Var)
      stack.push(current_scope[node.name])
    end

    def visit(node : IVar)
      stack.push(current_scope[node.name])
    end

    def visit(node : Const)
      stack.push(current_scope[node.name])
    end

    def visit(node : Underscore)
      stack.push(current_scope[node.name])
    end
  end
end
