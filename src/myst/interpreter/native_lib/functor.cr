module Myst
  class Interpreter
    NativeLib.method :func_to_s, TFunctor do
      this.inspect
    end


    def init_functor
      functor_type = __make_type("Functor", @kernel.scope)

      NativeLib.def_instance_method(functor_type, :to_s,  :func_to_s)

      functor_type
    end
  end
end
