class Myst::Interpreter
  def visit(node : AST::IfExpression)
    recurse(node.condition.not_nil!)
    if stack.pop().truthy?
      recurse(node.body)
    else
      if node.alternative
        recurse(node.alternative.not_nil!)
      else
        stack.push(TNil.new)
      end
    end
  end

  def visit(node : AST::UnlessExpression)
    recurse(node.condition.not_nil!)
    unless stack.pop().truthy?
      recurse(node.body)
    else
      if node.alternative
        recurse(node.alternative.not_nil!)
      else
        stack.push(TNil.new)
      end
    end
  end

  def visit(node : AST::ElseExpression)
    recurse(node.body)
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
