require "./interpreter/*"
require "./interpreter/nodes/*"
require "./interpreter/native_lib"

module Myst
  class Interpreter
    property stack : Array(Value)
    property self_stack : Array(Value)

    def initialize
      @stack = [] of Value
      @scope_stack = [] of Scope
      @self_stack = [TModule.new] of Value
    end


    def current_scope
      scope_override || current_self.scope
    end

    def scope_override
      @scope_stack.last?
    end

    def push_scope_override(scope : Scope = Scope.new)
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
  end
end
