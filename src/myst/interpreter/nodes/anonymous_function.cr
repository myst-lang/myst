module Myst
  class Interpreter
    def visit(node : AnonymousFunction)
      # Originally copied from `visit(node : Def)`. This should probably be
      # extracted to a more generic method for lexical scope resolution. The
      # difference between this and `__scopeof` is that this resolves to
      # `instance_scope` when `current_self` is a `TType`, which is the case
      # when defining methods on a type.
      scope =
        case type = current_self
        when TType
          type.instance_scope
        else
          current_scope
        end

      functor = TFunctor.new(node.internal_name, [] of Callable, scope, closure: true, closed_self: current_self)

      node.clauses.each do |clause|
        functor.add_clause(TFunctorDef.new(clause))
      end

      # The functor object is never added to the current scope. The purpose
      # of an anonymous function is exactly that, to be unnamed. Instead, the
      # value is simply pushed onto the stack. Users can then capture these
      # functors into variables via `*Assign`s or other captures.
      @stack.push(functor)
    end
  end
end
