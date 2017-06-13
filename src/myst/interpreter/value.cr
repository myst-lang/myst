require "./functor"

module Myst
  class Value
    alias BaseType = Int64 | Float64 | String | Bool | Functor | Nil

    property raw : BaseType

    def initialize; @raw = nil; end
    def initialize(@raw : BaseType); end


    def is_int?;      raw.is_a?(Int64); end
    def is_float?;    raw.is_a?(Float64); end
    def is_numeric?;  raw.is_a?(Int64 | Float64); end
    def is_string?;   raw.is_a?(String); end
    def is_bool?;     raw.is_a?(Bool); end
    def is_functor?;  raw.is_a?(Functor); end
    def is_nil?;      raw.is_a?(Nil); end

    def as_int;       raw.as(Int64); end
    def as_float;     raw.as(Float64); end
    def as_numeric;   raw.as(Int64 | Float64); end
    def as_string;    raw.as(String); end
    def as_functor;   raw.as(Functor); end
    def as_bool;      raw.as(Bool); end

    def not_nil!;     raw.not_nil!; end


    def type
      case raw
      when Int64
        "Integer"
      when Float64
        "Float"
      when String
        "String"
      when Bool
        "Bool"
      when Functor
        "Functor"
      when Nil
        "Nil"
      end
    end


    # IO

    def to_s
      @raw.to_s
    end

    def to_s(io : IO)
      io << to_s
    end

    # Return the string representation of this value with the appropriate
    # type punctuation (e.g., quotes around strings).
    def inspect
      case @raw
      when String
        '"' + @raw.to_s + '"'
      else
        @raw.to_s
      end
    end

    def inspect(io : IO)
      io << inspect
    end
  end
end
