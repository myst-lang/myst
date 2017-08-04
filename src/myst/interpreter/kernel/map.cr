module Myst::Kernel
  module Map
    include PrimitiveAPI

    primitive_func(TMap, :each, 0) do
      expect_block_arg

      this.value.each do |k, v|
        yield_to_block(k, v)
      end
      TNil.new
    end

    primitive_func(TMap, :to_s, 0) do
      TString.new(this.value.to_s)
    end
  end

  register_primitive_api Map
end
