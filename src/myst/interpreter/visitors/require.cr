require "../dependency_loader.cr"

class Myst::Interpreter
  def visit(node : AST::RequireStatement)
    recurse(node.path)
    result = DependencyLoader.require(stack.pop, node.working_dir)

    # If the code was loaded into a node, visit it to evalute it's contents.
    if result.is_a?(AST::Node)
      recurse(result)
    else
      # If the code was _not_ loaded, return a false value.
      stack.push(TBoolean.new(false))
    end
  end
end
