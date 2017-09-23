require "./value.cr"
require "./interpreter/*"

module Myst
  class Interpreter
    property stack : Array(Value)

    def initialize
      @stack = [] of Value
    end

    def visit(node : Node)
      node.accept_children(self)
    end
  end
end
