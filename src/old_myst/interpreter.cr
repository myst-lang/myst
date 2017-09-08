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


    def recurse(node)
      node.accept(self)
    end

    def push_scope(scope=Scope.new)
      @symbol_table.push_scope(scope)
    end

    def pop_scope
      @symbol_table.pop_scope
    end


    def visit(node : AST::Node)
      raise "Unsupported node `#{node.class.name}`"
    end
  end
end
