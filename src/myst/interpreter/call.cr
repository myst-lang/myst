class Myst::Interpreter
  struct Args
    property  positional : Array(Value)
    @block : TFunctor?
    def block; @block.not_nil!; end
    def block?; @block; end

    def initialize;
      @positional = [] of Value
    end
    def initialize(@positional); end
    def initialize(@positional, @block); end

    def arity
      positional.size
    end
  end


  class Call
    alias CallableT = TFunctor | TNativeFunctor

    property callable : CallableT
    property args : Args
    property intr : Interpreter

    def initialize(@callable : CallableT, @args, @intr)
    end


    def run
      case @callable
      when TFunctor
        call_functor(args)
      when TNativeFunctor
        call_native_functor(args)
      else
        raise "`#{@callable.class}` is not a callable type"
      end
    end


    private def call_functor(args : Args)
      func = @callable.as(TFunctor).clauses.first
      scope = Scope.new(func.parent)
      func.parameters.reverse.each_with_index do |param, idx|
        scope[param.name] = args.positional[idx]
      end
      scope["$block_argument"] = args.block if args.block?
      intr.push_scope(scope)
      intr.recurse(func.body)
      intr.pop_scope
    end

    private def call_native_functor(args : Args)
      func = @callable.as(TNativeFunctor)
      # TODO: Remove this once the receiver becomes an explicitly passed argument
      # for all function calls.
      args.positional.unshift(intr.stack.pop) if func.arity > args.positional.size
      intr.stack.push(func.call(args.positional, args.block?, intr))
    end
  end
end
