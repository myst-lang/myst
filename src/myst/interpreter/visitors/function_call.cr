class Myst::Interpreter
  def visit(node : AST::FunctionCall)
    recurse(node.receiver)
    func = stack.pop

    case func
    when TFunctor
      recurse(node.arguments)
      @symbol_table.push_scope(func.scope.full_clone)
      func.parameters.children.reverse_each do |param|
        @symbol_table.assign(param.name, stack.pop(), make_new: true)
      end
      if block_def = node.block
        recurse(block_def)
        @symbol_table.assign("$block_argument", stack.pop(), make_new: true)
      end
      recurse(func.body)
      @symbol_table.pop_scope()
    when TNativeFunctor
      recurse(node.arguments)
      args = [] of Value
      func.arity.times{ args << stack.pop() }
      if block_def = node.block
        recurse(block_def)
        stack.push(func.call(args.reverse, stack.pop().as(TFunctor), self))
      else
        stack.push(func.call(args.reverse, nil, self))
      end
    else
      raise "#{func} is not a functor value."
    end
  end
end
