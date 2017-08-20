class Myst::Interpreter
  def visit(node : AST::ExpressionList)
    node.children.each do |child|
      recurse(child)
    end
  end
end
