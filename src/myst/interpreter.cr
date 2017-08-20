require "./interpreter/value.cr"
require "./interpreter/scope.cr"
require "./interpreter/*"


module Myst
  class Interpreter
    property stack : StackMachine
    property symbol_table : SymbolTable

    def initialize
      @stack = StackMachine.new
      @symbol_table = SymbolTable.new
      @symbol_table.push_scope(Kernel::SCOPE)
    end


    macro recurse(node)
      {{node}}.accept(self)
    end


    def visit(node : AST::Node)
      raise "Unsupported node `#{node.class.name}`"
    end
  end
end
