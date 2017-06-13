module Myst
  class SymbolTable
    alias Scope = Hash(String, Value)

    property scopes : Array(Scope)

    def initialize
      @scopes = [Scope.new]
    end

    def [](identifier : String)
      scopes.reverse_each do |scope|
        return scope[identifier] if scope[identifier]?
      end

      raise IndexError.new
    end

    def []=(identifier : String, value : Value)
      assign(identifier, value, recurse: true)
    end

    def assign(identifier : String, value : Value, recurse=true)
      found = if recurse
        scopes.reverse_each do |scope|
          if scope[identifier]?
            scope[identifier] = value
            break true
          end
        end
      else
        false
      end

      unless found
        scopes.last[identifier] = value
      end
    end

    def push_scope
      scopes.push(Scope.new)
    end

    def pop_scope
      scopes.pop
    end
  end
end
