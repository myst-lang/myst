module Myst
  class TFloat < Primitive(Float64)
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
