module Myst::Kernel
  module Map
    include PrimitiveAPI

    primitive_func(TMap, :each, 0) do
      TNil.new
    end

    primitive_func(TMap, :to_s, 0) do
      TString.new(this.value.to_s)
    end
  end

  register_primitive_api Map
end
