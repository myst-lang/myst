module Myst
  class TString < Primitive(String)
    def self.type_name; "String"; end
    def type_name; self.class.type_name; end

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
