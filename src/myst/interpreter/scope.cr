require "./value.cr"

module Myst
  class Scope
    property parent : Scope?
    property values : Hash(String, MTValue)

    def initialize(@parent : Scope? = nil)
      @values = {} of String => MTValue
    end

    # The shorthand access notations (`[]?`, `[]`, `[]=`) will all fall back to
    # the parent scope if the value does not exist in this scope.
    #
    # The longhand `has_key?` and `assign` only operate on this scope.
    def []?(key : String) : MTValue?
      found = @values[key]?
      if found.nil?
        found = @parent.try(&.[key]?)
      end
      found
    end

    # A non-nilable variant of `[]?`. While this method may raise an exception,
    # it is not considered a "public" exception (it is not meant to be
    # reachable by userland code). Any instance where the exception propogates
    # outside of the interpreter should be considered a bug.
    def [](key : String) : MTValue
      found = self[key]?
      if found.nil?
        raise IndexError.new("Interpeter Bug: Unmanaged, failed attempt to access `#{key}` from scope: #{self.inspect}")
      end
      found
    end

    def []=(key : String, value : MTValue) : MTValue
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
      @values.has_key?(key)
    end

    def assign(key : String, value : MTValue)
      @values[key] = value
    end

    # Remove all values from this scope. Parent scopes are not affected.
    delegate each, clear, to: @values

    def inspect(io : IO)
      io << "<<Scope(#{@values.inspect} parent="
      @parent.inspect(io)
      io << ")>>"
    end
  end
end
