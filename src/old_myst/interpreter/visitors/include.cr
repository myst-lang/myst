class Myst::Interpreter
  def visit(node : AST::IncludeStatement)
    recurse(node.path)
    mod = stack.pop

    # For now, any value that acts as a Scope is allowed to be included.
    if mod.is_a?(Scope)
      @symbol_table.current_scope.insert_parent(mod)
    else
      raise "Attempted to include a non-scope value: #{mod.inspect}"
    end

    stack.push(mod)
  end
end
