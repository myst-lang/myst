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

  class FunctionMatchError < Exception
    def initialize(functor, args)
      @message = "Could not find matching clause for `#{functor.name}` with given arguments `#{args.inspect}`"
    end
  end


  class Call
    alias CallableT = TFunctor | TNativeFunctor

    property callable : CallableT
    property args : Args
    property intr : Interpreter
    property matcher : Matcher

    def initialize(@callable : CallableT, @args, @intr)
      @matcher = Matcher.new(@intr)
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
      func = @callable.as(TFunctor)
      if clause = lookup_clause(func, args)
        intr.recurse(clause.body)
        intr.pop_scope
      else
        raise FunctionMatchError.new(func, args)
      end
    end

    private def call_native_functor(args : Args)
      func = @callable.as(TNativeFunctor)
      # TODO: Remove this once the receiver becomes an explicitly passed
      # argument for all function calls.
      args.positional.unshift(intr.stack.pop) if func.arity > args.positional.size
      intr.stack.push(func.call(args.positional, args.block?, intr))
    end

    # Search through the clauses defined for the functor, using the given
    # arguments to find and return a matching clause. Each match attempt pushes
    # a temporary scope on the interpreter's symbol table. If the match
    # succeeds, the scope will be left on the stack for use during the
    # execution of the clause. If the match fails, the scope will be popped.
    private def lookup_clause(func : TFunctor, args : Args) : TFunctor::Clause?
      func.clauses.find do |clause|
        next unless args.positional.size == clause.arity

        begin
          # Create and push the temporary scope for the clause.
          scope = Scope.new(clause.parent)
          intr.push_scope(scope)
          # Iterate the parameters of the clause with their corresponding
          # arguments and match each.
          clause.parameters.zip(args.positional).each do |param, arg|
            @matcher.match(param.pattern, arg) if param.pattern?
            @matcher.match(param.name, arg) if param.name?
          end
          # Assign the implicit block argument. When block arguments are made
          # explicit in the future, this will be done conditionally.
          scope["$block_argument"] = args.block if args.block?
          # Getting here means the match was fully successful, so return the
          # clause, keeping the temporary scope on the table for later use.
          return clause
        rescue MatchError
          intr.pop_scope
          next
        end
      end

      return nil
    end
  end
end
