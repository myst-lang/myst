module Myst
  class Interpreter
    def visit(node : Call)
      receiver, func = lookup_call(node)

      case func
      when TFunctor
        visit_call(node, receiver, func)
      when MTValue
        # If `func` is _not_ a functor, it must just be a value from a variable
        # that didn't get parsed as a Var/Const/etc, so it can
        stack.push(func)
      else
        if (name = node.name).is_a?(String)
          __raise_not_found(name, receiver)
        else
          # Should be unreachable
          raise "Interpreter bug: "
        end
      end
    end


    private def lookup_call(node : Call) : Tuple(MTValue, MTValue?)
      # If the Call has a receiver, lookup the Call on that receiver, otherwise
      # search the current scope.
      receiver, check_current =
        case node.receiver?
        when Node
          node.receiver.accept(self)
          {stack.pop, false}
        else
          {current_self, true}
        end

      # TODO: Crystal 0.24.1 sometimes has an issue with reducing the types
      # of local variables inside of `case...when` expressions. Until, this
      # gets resolved, the explicit type casts on `name` and `raise` in the
      # `else` case are necessary :/
      func =
        case (name = node.name)
        when String
          recursive_lookup(receiver, name.as(String), check_current)
        when Node
          node.name.as(Node).accept(self)
          stack.pop
        else
          # Should be unreachable
          raise "Interpreter bug: `name` of Call node must be a String or a Node, but got #{node.name.class}"
        end

      {receiver, func}
    end


    private def visit_call(node, receiver, func : TFunctor)
      args = [] of MTValue

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

      original_callstack_size = @callstack.size
      @callstack.push(node.location, func.name)
      result = Invocation.new(self, func, receiver, args, block).invoke
      pop_callstack(to_size: original_callstack_size)
      stack.push(result)
    end
  end
end
