module Myst
  class TInteger < Primitive(Int64)
    def self.type_name; "Integer"; end
    def type_name; self.class.type_name; end

    simple_op :==, TInteger, returns: TBoolean
    simple_op :!=, TInteger, returns: TBoolean

    simple_op  :<, TInteger | TFloat, returns: TBoolean
    simple_op :<=, TInteger | TFloat, returns: TBoolean
    simple_op :>=, TInteger | TFloat, returns: TBoolean
    simple_op  :>, TInteger | TFloat, returns: TBoolean

    simple_op :+, TInteger
    simple_op :+, TFloat, returns: TFloat

    simple_op :-, TInteger
    simple_op :-, TFloat, returns: TFloat

    simple_op :*, TInteger
    simple_op :*, TFloat, returns: TFloat

    simple_op :/, TInteger
    simple_op :/, TFloat, returns: TFloat
  end
end
