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
      if func.is_a?(TFunctor) || func.is_a?(TNativeFunctor)
        args = node.args.map{ |a| a.accept(self); stack.pop }
        if node.block?
          node.block.accept(self)
          block = stack.pop.as(TFunctor)
        end
        result = do_call(func, receiver, args, block)
        stack.push(result)
      else
        raise "No method #{node.name} for receiver."
      end
    end

    def do_call(func : TFunctor, receiver : Value?, args : Array(Value), block : TFunctor?)
      clause = func.clauses.first

      push_scope
      clause.params.each_with_index do |p, idx|
        if p.name?
          current_scope.assign(p.name, args[idx])
        end
      end

      result =
        if clause.body.is_a?(Expressions)
          visit(clause.body)
          stack.pop
        else
          TNil.new
        end

      pop_scope
      return result
    end

    def do_call(func : TNativeFunctor, receiver : Value?, args : Array(Value), block : TFunctor?)
      func.impl.call(receiver, args, block, self)
    end
  end
end
