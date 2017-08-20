module Myst
  class TInteger < Primitive(Int64)
    def self.type_name; "Integer"; end
    def type_name; self.class.type_name; end

    def ==(other : Value)
      if other.is_a?(TFloat) || other.is_a?(TInteger)
        self.value == other.value
      else
        false
      end
    end

    def !=(other : Value)
      !(self == other)
    end

    def hash
      self.value
    end

    simple_op  :<, TInteger
    simple_op  :<, TFloat
    simple_op :<=, TInteger
    simple_op :<=, TFloat
    simple_op :>=, TInteger
    simple_op :>=, TFloat
    simple_op  :>, TInteger
    simple_op  :>, TFloat

    simple_op :+, TInteger
    simple_op :+, TFloat
    simple_op :-, TInteger
    simple_op :-, TFloat
    simple_op :*, TInteger
    simple_op :*, TFloat
    simple_op :/, TInteger
    simple_op :/, TFloat
  end
end
