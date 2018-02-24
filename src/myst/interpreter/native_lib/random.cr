module Myst
  class Interpreter
    NativeLib.method :random_rand, TModule, max : MTValue? = nil do
      if max.is_a? Int64
        rand(max)
      elsif max.is_a? Float64
        rand(max)
      else
        rand()
      end
    end

    def init_random(kernel : TModule)
      random_module = TModule.new("Random", kernel.scope)

      NativeLib.def_method(random_module, :rand, :random_rand)

      random_module
    end
  end
end
