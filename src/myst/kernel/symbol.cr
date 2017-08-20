module Myst::Kernel
  module Symbol
    include PrimitiveAPI

    primitive_func(TSymbol, :to_s, 0) do
      TString.new(this.name.to_s)
    end
  end

  register_primitive_api Symbol
end
