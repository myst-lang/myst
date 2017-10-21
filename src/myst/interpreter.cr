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
      @self_stack = [create_kernel] of Value
    end

    private def create_kernel
      kernel = TModule.new
      kernel.scope["Nil"]         = NIL_TYPE
      kernel.scope["Boolean"]     = BOOLEAN_TYPE
      kernel.scope["Integer"]     = INTEGER_TYPE
      kernel.scope["Float"]       = FLOAT_TYPE
      kernel.scope["String"]      = STRING_TYPE
      kernel.scope["Symbol"]      = SYMBOL_TYPE
      kernel.scope["List"]        = LIST_TYPE
      kernel.scope["Map"]         = MAP_TYPE
      kernel.scope["Functor"]     = FUNCTOR_TYPE
      kernel.scope["FunctorDef"]  = FUNCTOR_DEF_TYPE
      kernel.scope["NativeDef"]   = NATIVE_DEF_TYPE
      kernel.scope["Module"]      = MODULE_TYPE
      kernel.scope["Type"]        = TYPE_TYPE
      return kernel
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
