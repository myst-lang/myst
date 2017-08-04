module Myst::Kernel
  module List
    include PrimitiveAPI

    primitive_func(TList, :each, 0) do
      TNil.new
    end

    primitive_func(TList, :to_s, 0) do
      TString.new(this.value.to_s)
    end
  end

  register_primitive_api List
end
