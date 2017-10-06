module Myst
  class Interpreter
    def visit(node : Call)
      # If the Call has a receiver, lookup the Call on that receiver, otherwise
      # search the current scope.
      scope =
        if node.receiver?
          node.receiver.accept(self)
          receiver = stack.pop
          receiver.class.methods
        else
          current_scope
        end

      func = scope[node.name]?
      raise "No method #{node.name} for receiver." unless func.is_a?(TFunctor)

      args = node.args.map{ |a| a.accept(self); stack.pop }

      if node.block?
        node.block.accept(self)
        block = stack.pop.as(TFunctor)
      end

      result = Invocation.new(self, func, receiver, args, block).invoke
      stack.push(result)
    end
  end
end
