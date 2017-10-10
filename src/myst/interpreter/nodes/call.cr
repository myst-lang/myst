module Myst
  class Interpreter
    def visit(node : Call)
      # If the Call has a receiver, lookup the Call on that receiver, otherwise
      # search the current scope.
      scope =
        if node.receiver?
          node.receiver.accept(self)
          receiver = stack.pop
          receiver.methods
        else
          current_scope
        end

      visit_call(node, receiver, scope[node.name]?)
    end

    private def visit_call(node, receiver, func : TFunctor)
      args = node.args.map{ |a| a.accept(self); stack.pop }

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

    private def visit_call(_node, _receiver, _value)
      raise "No method #{_node.name} for #{_receiver}."
    end
  end
end
