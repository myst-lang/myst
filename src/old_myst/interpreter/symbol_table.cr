require "./scope"

module Myst
  class SymbolTable
    property scope_stack : Array(Scope)

    def initialize
      @scope_stack = [Scope.new]
    end

    def current_scope : Scope
      scope_stack.last
    end


    def []?(identifier : String)
      current_scope[identifier]?
    end

    def [](identifier : String)
      current_scope[identifier]
    end


    def []=(identifier : String, value : Value)
      assign(identifier, value)
    end


    def assign(identifier : String, value : Value, make_new=false)
      current_scope.assign(identifier, value, make_new)
    end


    def push_scope(scope : Scope = Scope.new)
      # Only set the parent of the scope if one doesn't exist. This allows
      # for implicit block scopes (`do...end`), as well as function scopes
      # where a context (parent scope) is needed.
      scope.parent = current_scope unless scope.parent
      scope_stack.push(scope)
    end

    def pop_scope
      scope_stack.pop
    end
  end
end
