require "./interpreter/*"
require "./interpreter/nodes/*"
require "./interpreter/native_lib"

module Myst
  class Interpreter
    property stack : Array(Value)
    property symbol_table : Scope

    def initialize
      @stack = [] of Value
      @symbol_table = Scope.new
    end

    def current_scope
      @symbol_table
    end

    def push_scope(scope : Scope = Scope.new)
      scope.parent ||= @symbol_table
      @symbol_table = scope
    end

    def pop_scope
      if @symbol_table.parent
        @symbol_table = @symbol_table.parent.not_nil!
      end
    end

    def visit(node : Node)
      node.accept_children(self)
    end
  end
end
