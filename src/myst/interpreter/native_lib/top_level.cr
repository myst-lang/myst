module Myst
  class Interpreter
    NativeLib.method :mt_exit, Value, status : TInteger? do
      real_status =
        if status.is_a?(TInteger)
          status.value
        else
          0
        end

      exit(real_status.to_i32)
    end


    def init_top_level(kernel : TModule)
      NativeLib.def_method(kernel, :exit, :mt_exit)
      kernel
    end
  end
end
