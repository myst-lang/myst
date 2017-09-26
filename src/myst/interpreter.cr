require "./interpreter/*"
require "./interpreter/nodes/*"

module Myst
  class Interpreter
    property stack : Array(Value)
    property symbol_table : Scope

    def initialize
      @stack = [] of Value
      @symbol_table = Scope.new
    end

    def visit(node : Node)
      node.accept_children(self)
    end
  end
end
