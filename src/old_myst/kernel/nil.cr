module Myst::Kernel
  module Nil
    include PrimitiveAPI

    primitive_func(TNil, :to_s, 0) do
      TString.new("nil")
    end
  end

  register_primitive_api Nil
end
