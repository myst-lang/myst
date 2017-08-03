module Myst
  class TInteger < Primitive(Int64)
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


    make_public_op(:to_s, 0) do
      TString.new(this.value.to_s)
    end
  end
end
