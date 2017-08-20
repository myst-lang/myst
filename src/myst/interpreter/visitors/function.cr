class Myst::Interpreter
  def visit(node : AST::FunctionDefinition)
    functor = TFunctor.new(node, @symbol_table.current_scope)
    @symbol_table[node.name] = functor
    stack.push(functor)
  end
end
