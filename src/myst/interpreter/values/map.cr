module Myst
  # Maps are essentially hashes from one value to another.
  # Performance at such a general level is not the best, but perhaps
  # special-case maps with only single-type keys (symbols or floats, in
  # particular) could help.
  class TMap < Primitive(Hash(Value, Value))
    def initialize(@value : Array(Value)); end

    def initialize(other_map : TMap)
      @value = other_map.value
    end

    def initialize
      @value = {} of Value => Value
    end

    def ==(other : TMap) : TBoolean
      TBoolean.new(false)
    end

    def !=(other : TMap) : TBoolean
      TBoolean.new(true)
    end

    simple_op :+, TMap
    simple_op :-, TMap


    def assign(key : Value, value : Value)
      @value[key] = value
    end

    def reference(key : Value)
      @value[key]? || TNil.new
    end

    def set(key : TInteger, new_value : Value)
      @value[key] = new_value
    end


    def to_s
      value_strings = @value.map do |key, value|
        # Show simplified syntax for symbol keys
        key.is_a?(TSymbol) ? "#{key}: #{value}" : "<#{key}>: #{value}"
      end

      "{#{value_strings.join(", ")}}"
    end
  end
end
