class Myst::Interpreter
  def visit(node : AST::Block)
    # If the block has no statements, push a nil value onto the stack as an
    # implicit return value.
    if node.children.empty?
      stack.push(TNil.new)
    else
      node.children.each_with_index do |child, index|
        recurse(child)
        # All expressions push a value onto the stack. The top-level expression
        # will return an unused value, which should be popped from the stack to
        # avoid leaking memory. However, the last expression in a block is the
        # implicit return value, so it should stay on the stack.
        stack.pop unless index == node.children.size - 1
      end
    end
  end
end
