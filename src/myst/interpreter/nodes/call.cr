module Myst
  class Interpreter
    def visit(node : Call)
      receiver, func = lookup_call(node)

      @callstack.push(node)
      if func
        visit_call(node, receiver, func)
      else
        raise_not_found(node.name, receiver)
      end
      @callstack.pop
    end


    private def lookup_call(node : Call) : Tuple(Value, Value?)
      # If the Call has a receiver, lookup the Call on that receiver, otherwise
      # search the current scope.
      receiver =
        if node.receiver?
          node.receiver.accept(self)
          stack.pop
        else
          current_self
        end

      func = recursive_lookup(receiver, node.name)

      {receiver, func}
    end


    private def visit_call(node, receiver, func : TFunctor)
      args = [] of Value

      node.args.each do |elem|
        elem.accept(self)
        # A Splat in a List literal should have its result concatenated in
        # place into the arguments. In other words, a Splat should act like the
        # elements of the result were given directly as positional arguments.
        if elem.is_a?(Splat)
          # The result of a Splat _must_ be a list, so this assertion should
          # never fail.
          splat_result = stack.pop.as(TList)
          args.concat(splat_result.elements)
        else
          args << stack.pop
        end
      end

      if node.block?
        node.block.accept(self)
        block = stack.pop.as(TFunctor)
      end

      result = Invocation.new(self, func, receiver, args, block).invoke
      stack.push(result)
    end

    private def visit_call(_node, _receiver, value : Value)
      stack.push(value)
    end
  end
end
