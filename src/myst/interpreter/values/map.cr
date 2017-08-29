module Myst
  # Maps are essentially hashes from one value to another.
  # Performance at such a general level is not the best, but perhaps
  # special-case maps with only single-type keys (symbols or floats, in
  # particular) could help.
  class TMap < Primitive(Hash(Value, Value))
    def self.type_name; "Map"; end
    def type_name; self.class.type_name; end

    def initialize(other_map : TMap)
      @value = other_map.value
    end

    def initialize
      @value = {} of Value => Value
    end

    def ==(other : TMap)
      @value.each do |(key, value)|
        return false if value != other.value[key]
      end

      true
    end

    def !=(other : TMap)
      @value.each do |(key, value)|
        return true if value != other.value[key]
      end

      false
    end

    simple_op :+, TMap
    simple_op :-, TMap


    def assign(key : Value, value : Value)
      @value[key] = value
    end

    def reference(key : Value)
      @value[key]? || TNil.new
    end

    def has_key?(key : Value)
      @value[key]? || false
    end

    def set(key : Value, new_value : Value)
      @value[key] = new_value
    end

    def hash
      # Only sum hashes of keys for the sake of speed.
      @value.keys.sum(&.hash)
    end


    def to_s
      value_strings = @value.map do |key, value|
        # Show simplified syntax for symbol keys
        case key
        when TSymbol
          "#{key}: #{value}"
        when TString
          "<\"#{key}\">: #{value}"
        else
          "<#{key}>: #{value}"
        end
      end

      "{#{value_strings.join(", ")}}"
    end
  end
end
