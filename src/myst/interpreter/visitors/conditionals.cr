class Myst::Interpreter
  def visit(node : AST::WhenExpression)
    # Assignments in conditions for `when` blocks will _always_ create new
    # variables. This is important for being able to chain `when`s predictably.
    # As soon as the condition is evaluated, however, the scope restriction is
    # lifted and outside variables may be assigned to again.
    block_scope = Scope.new
    block_scope.restrict_assignments = true
    self.push_scope(block_scope)

    recurse(node.condition.not_nil!)
    if stack.pop.truthy?
      block_scope.restrict_assignments = false
      recurse(node.body)
      self.pop_scope
    else
      block_scope.clear
      if node.alternative
        recurse(node.alternative.not_nil!)
      else
        stack.push(TNil.new)
      end
    end
  end

  def visit(node : AST::UnlessExpression)
    block_scope = Scope.new
    block_scope.restrict_assignments = true
    self.push_scope(block_scope)

    recurse(node.condition.not_nil!)
    unless stack.pop().truthy?
      block_scope.restrict_assignments = false
      recurse(node.body)
    else
      block_scope.clear
      if node.alternative
        recurse(node.alternative.not_nil!)
      else
        stack.push(TNil.new)
      end
    end
  end

  def visit(node : AST::ElseExpression)
    self.push_scope
    recurse(node.body)
    self.pop_scope
  end

  def visit(node : AST::WhileExpression)
    recurse(node.condition)
    while stack.pop().truthy?
      recurse(node.body)
      recurse(node.condition)
    end
  end

  def visit(node : AST::UntilExpression)
    recurse(node.condition)
    until stack.pop().truthy?
      recurse(node.body)
      recurse(node.condition)
    end
  end
end
