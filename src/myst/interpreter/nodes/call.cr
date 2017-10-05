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

      if (func = scope[node.name]?).is_a?(TFunctor)
        args = node.args.map{ |a| a.accept(self); stack.pop }
        if node.block?
          node.block.accept(self)
          block = stack.pop.as(TFunctor)
        end
        result = do_call(func.clauses.first, receiver, args, block)
        stack.push(result)
      else
        raise "No method #{node.name} for receiver."
      end
    end

    def do_call(func : TFunctorDef, receiver : Value?, args : Array(Value), block : TFunctor?)
      push_scope
      func.params.each_with_index do |p, idx|
        if p.name?
          current_scope.assign(p.name, args[idx])
        end
      end

      visit(func.body)
      result = stack.pop

      pop_scope
      return result
    end

    def do_call(func : TNativeDef, receiver : Value?, args : Array(Value), block : TFunctor?)
      func.impl.call(receiver, args, block, self)
    end

    def do_call(_func : Callable, _receiver, _args, _block)
      raise "Unsupported callable type #{_func.class}"
    end
  end
end
