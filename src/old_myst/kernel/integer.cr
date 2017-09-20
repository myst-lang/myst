module Myst::Kernel
  module Integer
    include PrimitiveAPI

    primitive_func(TInteger, :to_s, 0) do
      TString.new(this.value.to_s)
    end
  end

  register_primitive_api Integer
end
