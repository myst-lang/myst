module Myst
  class TString < Primitive(String)
    def self.type_name; "String"; end
    def type_name; self.class.type_name; end

    def ==(other : TString)
      self.value == other.value
    end

    def ==(other : TSymbol)
      self.value == other.name
    end

    def ==(other : Value)
      false
    end

    def !=(other : Value)
      !(self == other)
    end

    def hash
      self.value.hash
    end

    simple_op  :<, TString
    simple_op :<=, TString
    simple_op :>=, TString
    simple_op  :>, TString

    simple_op :+, TString
    simple_op :*, TInteger, returns: TString
  end
end
