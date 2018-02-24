module Myst
  class Interpreter
    NativeLib.method :random_rand, TModule, max : MTValue? = nil do
      if max.is_a? TInteger
        TInteger.new(rand(max.value))
      elsif max.is_a? TFloat
        TFloat.new(rand(max.value))
      else
        TFloat.new(rand())
      end
    end

    def init_random(kernel : TModule)
      random_module = TModule.new("Random", kernel.scope)

      NativeLib.def_method(random_module, :rand, :random_rand)

      random_module
    end
  end
end
