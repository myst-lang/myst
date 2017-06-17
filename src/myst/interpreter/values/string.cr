module Myst
  class TString < Primitive(String)
    simple_op :==, TString, returns: TBoolean
    simple_op :!=, TString, returns: TBoolean

    simple_op  :<, TString, returns: TBoolean
    simple_op :<=, TString, returns: TBoolean
    simple_op :>=, TString, returns: TBoolean
    simple_op  :>, TString, returns: TBoolean

    simple_op :+, TString
    simple_op :*, TInteger, returns: TString
  end
end
