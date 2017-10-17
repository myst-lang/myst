module Myst
  class Interpreter
    def visit(node : Call)
      # If the Call has a receiver, lookup the Call on that receiver, otherwise
      # search the current scope.
      receiver =
        if node.receiver?
          node.receiver.accept(self)
          stack.pop
        else
          current_self
        end

      func    = current_scope[node.name] if current_scope.has_key?(node.name)
      func  ||= receiver.scope[node.name]?
      func  ||= receiver.ancestors.each do |anc|
        if found = anc.scope[node.name]?
          break found
        end
      end

      visit_call(node, receiver, func)
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
