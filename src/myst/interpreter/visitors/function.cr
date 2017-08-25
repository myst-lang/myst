class Myst::Interpreter
  def visit(node : AST::FunctionDefinition)
    if (functor = @symbol_table[node.name]?)
      if functor.is_a?(TFunctor)
        functor.add_clause(node)
      else
        raise "Redefinition of `#{node.name}` as a function. Already defined as a #{functor.type_name}"
    else
      functor = TFunctor.new(node, @symbol_table.current_scope)
      @symbol_table[node.name] = functor
    end
    stack.push(functor)
  end
end
