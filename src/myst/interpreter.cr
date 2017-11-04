require "./interpreter/*"
require "./interpreter/nodes/*"
require "./interpreter/native_lib"

module Myst
  class Interpreter
    property stack : Array(Value)
    property self_stack : Array(Value)
    property callstack : Callstack
    property kernel : TModule

    property output : IO
    property errput : IO


    def initialize(@output : IO = STDOUT, @errput : IO = STDERR)
      @stack = [] of Value
      @scope_stack = [] of Scope
      @callstack = Callstack.new
      @kernel = create_kernel
      @self_stack = [@kernel] of Value
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


    def current_self
      self_stack.last
    end

    def push_self(new_self : Value)
      self_stack.push(new_self)
    end

    def pop_self
      self_stack.pop
    end


    def visit(node : Node)
      raise "Compiler bug: #{node} nodes are not yet supported."
    end


    def warn(message : String)
      @errput.puts("WARNING: #{message}")
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

    def run(program)
      visit(program)
    rescue err : RuntimeError
      put_error(err)
    end
  end
end
