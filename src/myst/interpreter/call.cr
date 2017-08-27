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
        @intr.recurse(clause.body)
        @intr.pop_scope
      else
        raise FunctionMatchError.new(func, args)
      end
    end

    private def call_native_functor(args : Args)
      func = @callable.as(TNativeFunctor)
      # TODO: Remove this once the receiver becomes an explicitly passed
      # argument for all function calls.
      args.positional.unshift(@intr.stack.pop) if func.arity > args.positional.size
      @intr.stack.push(func.call(args.positional, args.block?, @intr))
    end

    # Search through the clauses defined for the functor, using the given
    # arguments to find and return a matching clause. Each match attempt pushes
    # a temporary scope on the interpreter's symbol table. If the match
    # succeeds, the scope will be left on the stack for use during the
    # execution of the clause. If the match fails, the scope will be popped.
    private def lookup_clause(func : TFunctor, args : Args) : TFunctor::Clause?
      func.clauses.find do |clause|
        # If the clause contains a splat argument, the number of positional
        # arguments in the call must be at least the number of normal
        # positional arguments.
        if clause.parameters.splat
          args.positional.size >= clause.arity - 1
        else
          args.positional.size == clause.arity
        end

        begin
          # Create and push the temporary scope for the clause.
          scope = Scope.new(clause.parent)
          @intr.push_scope(scope)

          # Because splat collectors can appear anywhere in the parameter list,
          # arguments cannot simply be matched in order. Instead, start by
          # iterating in order, but once a splat parameter is seen, shift to
          # iterating from the right until the splat is seen again. At that
          # point, collect the remaining positional arguments into the splat
          # collector.
          positionals = args.positional.dup
          # .shift will pull arguments off the left side of the list.
          clause.parameters.left.each { |param| match_positional_arg(param, positionals.shift) }
          # .pop will pull arguments off the right side.
          clause.parameters.right.each{ |param| match_positional_arg(param, positionals.pop)   }
          # The remaining arguments get collected into the splat.
          if clause.parameters.splat
            fill_splat(clause.parameters.splat, positionals)
            positionals.clear
          end

          raise "Parameter count not matched" unless positionals.empty?

          # Assign the implicit block argument. When block arguments are made
          # explicit in the future, this will be done conditionally.
          scope["$block_argument"] = args.block if args.block?
          # Getting here means the match was fully successful, so return the
          # clause, keeping the temporary scope on the table for later use.
          return clause
        rescue
          @intr.pop_scope
          next
        end
      end

      return nil
    end

    private def match_positional_arg(param : AST::FunctionParameter, arg : Value)
      @matcher.match(param.pattern, arg) if param.pattern?
      @matcher.match(param.name, arg) if param.name?
    end

    private def fill_splat(param : AST::FunctionParameter, args : Array(Value))
      # If the splat is unnamed, it's value does not need to be set.
      @matcher.match(param.name, TList.new(args)) if param.name?
    end
    # If no splat is given, nothing should happen
    private def fill_splat(param : Nil, args : Array(Value)); end
  end
end
