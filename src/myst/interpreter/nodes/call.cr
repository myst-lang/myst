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

      case func = scope[node.name]?
      when TNativeFunctor
        do_native_call(node, receiver, func)
      else
        raise "No method #{node.name} for receiver."
      end
    end

    def do_native_call(node : Call, receiver : Value?, func : TNativeFunctor)
      args = node.args.map{ |a| a.accept(self); stack.pop }
      result = func.impl.call(receiver, args, nil, self)
      stack.push(result)
    end
  end
end
