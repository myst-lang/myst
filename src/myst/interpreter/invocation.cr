module Myst
  # An Invocation is a binding of the interpreter, a function, and arguments
  # for the function together to represent a Call.
  #
  # In essence, an Invocation is the step between the Call node in the AST and
  # the result of calling a function. Functor resolution happens before
  # creating an Invocation, meaning they can be passed around without concern
  # for lexical scoping or the like. However, the _entire_ functor is carried
  # with an Invocation; matching to a specific definition does not happen until
  # the Invocation is invoked.
  struct Invocation
    property  itr       : Interpreter
    property  func      : TFunctor
    property! receiver  : Value?
    property  args      : Array(Value)
    property! block     : TFunctor?

    def initialize(@itr : Interpreter, @func : TFunctor, @receiver : Value?, @args : Array(Value), @block : TFunctor?)
    end

    def invoke
      do_call(@func.clauses.first, @receiver, @args, @block)
    end


    private def do_call(func : TFunctorDef, receiver : Value?, args : Array(Value), block : TFunctor?)
      @itr.push_scope
      func.params.each_with_index do |p, idx|
        if p.name?
          @itr.current_scope.assign(p.name, args[idx])
        end
      end

      @itr.visit(func.body)
      result = @itr.stack.pop

      @itr.pop_scope
      return result
    end

    private def do_call(func : TNativeDef, receiver : Value?, args : Array(Value), block : TFunctor?)
      func.impl.call(receiver, args, block, @itr)
    end

    private def do_call(_func, _receiver, _args, _block)
      raise "Unsupported callable type #{_func.class}"
    end
  end
end
