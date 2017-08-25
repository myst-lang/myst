class Myst::Interpreter
  def visit(node : AST::FunctionDefinition)
    if (functor = @symbol_table[node.name]?) && functor.is_a?(TFunctor)
      functor.add_clause(node)
    else
      functor = TFunctor.new(node, @symbol_table.current_scope)
      @symbol_table[node.name] = functor
    end
    stack.push(functor)
  end
end
