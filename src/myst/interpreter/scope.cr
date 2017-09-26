require "./value.cr"

module Myst
  class Scope
    property parent : Scope?
    property values : Hash(String, Value)

    def initialize(@parent : Scope? = nil)
      @values = {} of String => Value
    end

    # The shorthand access notations (`[]?`, `[]`, `[]=`) will all fall back to
    # the parent scope if the value does not exist in this scope.
    #
    # The longhand `has_key?` and `assign` only operate on this scope.
    def []?(key : String)
      @values[key]? || ((p = @parent) && p[key]?)
    end

    def [](key : String)
      self[key]? || raise IndexError.new
    end

    def []=(key : String, value : Value)
      scope = self
      while scope
        if scope.has_key?(key)
          return scope.assign(key, value)
        end
        scope = scope.parent
      end

      # This point is only hit if the key did not exist in any parent scope.
      assign(key, value)
    end


    def has_key?(key : String)
      !!@values[key]?
    end

    def assign(key : String, value : Value)
      @values[key] = value
    end
  end
end
