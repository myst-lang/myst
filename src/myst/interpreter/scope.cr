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
    def []?(key : String) : Value?
      @values[key]? || @parent.try(&.[key]?)
    end

    # A non-nilable variant of `[]?`. While this method may raise an exception,
    # it is not considered a "public" exception (it is not meant to be
    # reachable by userland code). Any instance where the exception propogates
    # outside of the interpreter should be considered a bug.
    def [](key : String) : Value
      self[key]? || raise IndexError.new("Interpeter Bug: Unmanaged, failed attempt to access `#{key}` from scope: #{self.inspect}")
    end

    def []=(key : String, value : Value) : Value
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

    # Remove all values from this scope. Parent scopes are not affected.
    delegate each, clear, to: @values
  end
end
