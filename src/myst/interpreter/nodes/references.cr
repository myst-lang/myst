module Myst
  class Interpreter
    def visit(node : Var)
      stack.push(@symbol_table[node.name])
    end

    def visit(node : IVar)
      stack.push(@symbol_table[node.name])
    end

    def visit(node : Const)
      stack.push(@symbol_table[node.name])
    end

    def visit(node : Underscore)
      stack.push(@symbol_table[node.name])
    end
  end
end
