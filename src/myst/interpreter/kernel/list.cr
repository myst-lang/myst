module Myst::Kernel
  module List
    include PrimitiveAPI

    primitive_func(TList, :each, 0) do
      expect_block_arg

      this.value.each do |e|
        yield_to_block(e)
      end
      TNil.new
    end

    primitive_func(TList, :to_s, 0) do
      TString.new(this.value.to_s)
    end
  end

  register_primitive_api List
end
