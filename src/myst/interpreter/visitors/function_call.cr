require "../call.cr"

class Myst::Interpreter
  def visit(node : AST::FunctionCall)
    recurse(node.receiver)
    func = stack.pop

    # Collect all of the arguments given to the function
    case func
    when Call::CallableT
      args = Args.new(get_inline_args(node), get_block_arg(node))
      Call.new(func, args, self).run
    else
      raise "#{func} is not a callable value."
    end
  end


  private def get_inline_args(node) : Array(Value)
    recurse(node.arguments)
    # Shorthand way of popping the same number of arguments as were given at
    # the call site and maintaining their order.
    node.arguments.children.map{ stack.pop }.reverse
  end

  private def get_block_arg(node) : TFunctor?
    if block_def = node.block
      recurse(block_def)
      return stack.pop.as(TFunctor)
    end
  end
end
