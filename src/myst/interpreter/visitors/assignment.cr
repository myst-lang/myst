class Myst::Interpreter
  def visit(node : AST::SimpleAssignment)
    recurse(node.value)
    target = node.target

    # If the target is an identifier, recursing is unnecessary.
    if target.is_a?(AST::Ident) || target.is_a?(AST::Const)
      # The return value of an assignment is the value being assigned,
      # so there is no need to pop it from the stack. This also ensures
      # that the value is treated as a reference, rather than a copy.
      @symbol_table[target.name] = stack.last
    else
      raise "Cannot assign to `#{node.class}`. Must be either Ident or Const."
    end
  end
end
