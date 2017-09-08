module Myst::Kernel
  module Float
    include PrimitiveAPI

    primitive_func(TFloat, :to_s, 0) do
      TString.new(this.value.to_s)
    end
  end

  register_primitive_api Float
end
