require "./interpreter/*"
require "./interpreter/nodes/*"
require "./interpreter/native_lib"

module Myst
  class Interpreter
    property stack : Array(Value)
    property self_stack : Array(Value)

    property output : IO
    property errput : IO


    def initialize(@output : IO = STDOUT, @errput : IO = STDERR)
      @stack = [] of Value
      @scope_stack = [] of Scope
      @self_stack = [KERNEL] of Value

      init_kernel
    end

    private def init_kernel
      KERNEL.scope.clear
      KERNEL.scope["Nil"]         = NIL_TYPE
      KERNEL.scope["Boolean"]     = BOOLEAN_TYPE
      KERNEL.scope["Integer"]     = INTEGER_TYPE
      KERNEL.scope["Float"]       = FLOAT_TYPE
      KERNEL.scope["String"]      = STRING_TYPE
      KERNEL.scope["Symbol"]      = SYMBOL_TYPE
      KERNEL.scope["List"]        = LIST_TYPE
      KERNEL.scope["Map"]         = MAP_TYPE
      KERNEL.scope["Functor"]     = FUNCTOR_TYPE
      KERNEL.scope["FunctorDef"]  = FUNCTOR_DEF_TYPE
      KERNEL.scope["NativeDef"]   = NATIVE_DEF_TYPE
      KERNEL.scope["Module"]      = MODULE_TYPE
      KERNEL.scope["Type"]        = TYPE_TYPE
      KERNEL.scope["IO"]          = IO_MODULE
    end


    def current_scope
      scope_override || current_self.scope
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
      raise "#{node} nodes are not yet supported."
    end

    def put_error(error : RuntimeError)
      value_to_s = error.value.scope["to_s"].as(TFunctor)
      result = Invocation.new(self, value_to_s, error.value, [] of Value, nil).invoke
      @errput.puts(result.as(TString).value)
    end

    def run(program)
      visit(program)
    rescue err : RuntimeError
      put_error(err)
    end
  end
end
