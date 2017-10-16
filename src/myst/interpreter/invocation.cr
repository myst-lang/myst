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
      # If the invocation has a receiver, use it as the current value of `self`
      # for the duration of the Invocation.
      @itr.push_self(@receiver.not_nil!) if @receiver

      result = @func.clauses.each do |clause|
        @itr.push_scope_override(Scope.new(@func.lexical_scope))
        if clause_matches?(clause, @args.dup)
          res = do_call(clause, @receiver, @args, @block)
        end
        @itr.pop_scope_override
        break res if res
      end

      # After the invocation, restore the current value of `self` to whatever
      # it had been previously.
      @itr.pop_self if @receiver
      result || raise "No clause matches with given arguments: #{@args.inspect}"
    end


    private def clause_matches?(clause : TFunctorDef, args)
      begin
        left, splat, right = chunk_params(clause)
        left.each { |param| match_positional_arg(param, args.shift) }
        right.each{ |param| match_positional_arg(param, args.pop)   }

        if splat.is_a?(Param)
          @itr.match(Var.new(splat.name), TList.new(args))
        else
          unless args.empty?
            raise "All parameters not matched for clause"
          end
        end

        if self.block? && clause.block_param?
          @itr.match(Var.new(clause.block_param.name), self.block)
        elsif (self.block? && !clause.block_param?) || (!self.block? && clause.block_param?)
          raise "Unmatched block parameter"
        end

        return do_call(clause, @receiver, @args, @block)
      rescue
        false
      end
    end

    private def clause_matches?(clause : TNativeDef, args)
      if @args.size == clause.arity
        return do_call(clause, @receiver, @args, @block)
      else
        false
      end
    end

    private def clause_matches?(_func, _args)
      false
    end

    private def match_positional_arg(param, arg)
      @itr.match(param.pattern, arg)        if param.pattern?
      @itr.match(Var.new(param.name), arg)  if param.name?
    end


    private def do_call(func : TFunctorDef, receiver : Value?, args : Array(Value), block : TFunctor?)
      @itr.visit(func.body)
      return @itr.stack.pop
    end

    private def do_call(func : TNativeDef, receiver : Value?, args : Array(Value), block : TFunctor?)
      func.impl.call(receiver, args, block, @itr)
    end

    private def do_call(_func, _receiver, _args, _block)
      raise "Unsupported callable type #{_func.class}"
    end


    # Return a 3-tuple representing the segments of a List pattern in the
    # format `{pre-splat, splat-collector, post-splat}`. The splat collector
    # will be the single splat collector in the parameter list. The parser
    # ensures that only one splat collector will be present in the list.
    private def chunk_params(clause)
      left  = [] of Param
      splat = nil
      right = [] of Param

      past_splat = false
      clause.params.each do |el|
        if el.splat?
          splat = el
          past_splat = true
        elsif past_splat
          right.unshift(el)
        else
          left.push(el)
        end
      end

      {left, splat, right}
    end
  end
end
