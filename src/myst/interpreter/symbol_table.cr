require "./scope"

module Myst
  class SymbolTable
    property current_scope : Scope

    def initialize
      @current_scope = Scope.new
    end

    def []?(identifier : String)
      scope = @current_scope
      while scope
        return scope[identifier] if scope[identifier]?
        break if scope.restrictive?
        scope = scope.parent
      end
    end

    def [](identifier : String)
      self[identifier] || raise IndexError.new
    end


    def []=(identifier : String, value : Value)
      assign(identifier, value)
    end


    def assign(identifier : String, value : Value, make_new=false)
      if make_new
        return @current_scope[identifier] = value
      else
        scope = @current_scope
        while scope
          return scope[identifier] = value if scope[identifier]?
          break if scope.restrictive?
          scope = scope.parent
        end

        return @current_scope[identifier] = value
      end
    end


    def push_scope(scope : Scope = Scope.new)
      # Only set the parent of the scope if one doesn't exist. This allows
      # for implicit block scopes (`do...end`), as well as function scopes
      # where a context (parent scope) is needed.
      scope.parent = @current_scope unless scope.parent
      @current_scope = scope
    end

    def pop_scope
      @current_scope = @current_scope.parent.not_nil!
    end
  end
end
