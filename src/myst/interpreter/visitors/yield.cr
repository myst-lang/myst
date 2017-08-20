class Myst::Interpreter
  def visit(node : AST::YieldExpression)
    # Block accessibility is limited to the current scope. If a function
    # given a block in turn calls another function that `yield`s but does not
    # provide a block, the inner function should not be able to `yield` to
    # the outer function's block. Instead, an error should be raised that the
    # inner function expected a block argument.
    if block = @symbol_table.current_scope["$block_argument"]?.as(TFunctor)
      recurse(node.arguments)
      @symbol_table.push_scope(block.scope.full_clone)
      block.parameters.children.reverse_each do |param|
        @symbol_table.assign(param.name, stack.pop(), make_new: true)
      end
      recurse(block.body)
      @symbol_table.pop_scope()
    else
      raise "Attempted to yield when no block was given."
    end
  end
end
