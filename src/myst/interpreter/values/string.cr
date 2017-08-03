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

    make_public_op(:split, 0) do
      list = TList.new
      this.value.split.each do |elem|
        list.push(TString.new(elem))
      end

      list
    end
  end
end
