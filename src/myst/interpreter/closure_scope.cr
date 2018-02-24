require "./scope.cr"
require "./value.cr"

module Myst
  # A ClosureScope is a specially kind of Scope that allows direct access to
  # closured entries from the parent scope, but also does _not_ allow access to
  # scopes beyond the parent.
  class ClosureScope < Scope
    property closed_scope : Scope

    def initialize(@closed_scope : Scope, @parent : Scope? = nil)
      @values = {} of String => MTValue
    end

    def []?(key : String)
      if closed_scope.has_key?(key)
        closed_scope[key]
      else
        @values[key]?
      end
    end

    def []=(key : String, value : MTValue)
      if closed_scope.has_key?(key)
        closed_scope.assign(key, value)
      else
        assign(key, value)
      end
    end

    def has_key?(key : String)
      !!@values[key]? || closed_scope.has_key?(key)
    end

    def assign(key : String, value : MTValue)
      if closed_scope.has_key?(key)
        closed_scope.assign(key, value)
      else
        @values[key] = value
      end
    end
  end
end
