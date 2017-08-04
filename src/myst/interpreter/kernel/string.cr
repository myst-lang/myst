module Myst::Kernel
  module String
    include PrimitiveAPI

    primitive_func(TString, :to_s, 0) do
      TString.new(this.value.to_s)
    end

    primitive_func(TString, :split, 0) do
      list = TList.new
      this.value.split{ |elem| list.push(TString.new(elem)) }
      list
    end
  end

  register_primitive_api String
end
