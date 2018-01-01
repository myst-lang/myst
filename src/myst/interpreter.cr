require "./interpreter/*"
require "./interpreter/nodes/*"
require "./interpreter/native_lib"

module Myst
  class Interpreter
    property stack : Array(Value)
    property self_stack : Array(Value)
    property callstack : Callstack
    property kernel : TModule

    property input : IO
    property output : IO
    property errput : IO

    property warnings : Int32

    def initialize(@input : IO = STDIN, @output : IO = STDOUT, @errput : IO = STDERR)
      @stack = [] of Value
      @scope_stack = [] of Scope
      @callstack = Callstack.new
      @kernel = create_kernel
      @self_stack = [@kernel] of Value
      @warnings = 0
    end


    def current_scope
      scope_override || __scopeof(current_self)
    end

    def scope_override
      @scope_stack.last?
    end

    def push_scope_override(scope : Scope = Scope.new)
      scope.parent ||= current_scope
      @scope_stack.push(scope)
    end

    def pop_scope_override
      @scope_stack.pop
    end

    def pop_scope_override(to_size : Int)
      return unless to_size >= 0

      count_to_pop = @scope_stack.size - to_size
      if count_to_pop > 0
        @scope_stack.pop(count_to_pop)
      end
    end


    def current_self
      self_stack.last
    end

    def push_self(new_self : Value)
      self_stack.push(new_self)
    end

    def pop_self
      self_stack.pop
    end

    def pop_self(to_size : Int)
      return unless to_size >= 0

      count_to_pop = self_stack.size - to_size
      if count_to_pop > 0
        self_stack.pop(count_to_pop)
      end
    end


    def visit(node : Node)
      raise "Interpreter bug: #{node.class.name} nodes are not yet supported."
    end


    def warn(message : String, node : Node)
      @warnings += 1
      unless ENV["MYST_ENV"] == "test"
        @errput.puts("WARNING: #{message}")
        @errput.puts("  from `#{node.name}` at #{node.location.to_s}")
      end
    end


    def put_error(error : RuntimeError)
      value_to_s = __scopeof(error.value)["to_s"].as(TFunctor)
      result = Invocation.new(self, value_to_s, error.value, [] of Value, nil).invoke
      @errput.puts("Uncaught Exception: " + result.as(TString).value)
      error.trace.reverse_each do |frame|
        if frame.responds_to?(:name)
          @errput.puts "  from `#{frame.name}` at #{frame.location}"
        else
          @errput.puts "  at #{frame.location}"
        end
      end
    end

    def run(program, capture_errors=true)
      visit(program)
    rescue err : RuntimeError
      if capture_errors
        put_error(err)
      else
        raise err
      end
    end
  end
end
