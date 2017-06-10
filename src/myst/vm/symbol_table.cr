module Myst
  module VM
    class SymbolTable
      alias MTValue = Float64
      alias Scope = Hash(String, MTValue)

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

      def []=(identifier : String, value : MTValue)
        found = scopes.reverse_each do |scope|
          if scope[identifier]?
            scope[identifier] = value
            break true
          end
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
end
