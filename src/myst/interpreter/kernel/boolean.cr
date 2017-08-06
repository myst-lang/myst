module Myst::Kernel
  module Boolean
    include PrimitiveAPI

    primitive_func(TBoolean, :to_s, 0) do
      TString.new(this.value ? "true" : "false")
    end
  end

  register_primitive_api Boolean
end
