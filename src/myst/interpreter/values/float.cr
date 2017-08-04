module Myst
  class TFloat < Primitive(Float64)
    def self.type_name; "Float"; end
    def type_name; self.class.type_name; end

    simple_op :==, TFloat, returns: TBoolean
    simple_op :!=, TFloat, returns: TBoolean

    simple_op  :<, TInteger | TFloat, returns: TBoolean
    simple_op :<=, TInteger | TFloat, returns: TBoolean
    simple_op :>=, TInteger | TFloat, returns: TBoolean
    simple_op  :>, TInteger | TFloat, returns: TBoolean

    simple_op :+, TFloat
    simple_op :+, TInteger, returns: TFloat

    simple_op :-, TFloat
    simple_op :-, TInteger, returns: TFloat

    simple_op :*, TFloat
    simple_op :*, TInteger, returns: TFloat

    simple_op :/, TFloat
    simple_op :/, TInteger, returns: TFloat
  end
end
