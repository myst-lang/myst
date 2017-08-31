class Myst::Interpreter
  def visit(node : AST::Ident | AST::Const)
    if value = @symbol_table[node.name]?
      stack.push(value)
    else
      raise "Undefined variable `#{node.name}` in current scope."
    end
  end
end
