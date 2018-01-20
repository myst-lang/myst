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

    NativeLib.method :mt_sleep, Value, time : TInteger | TFloat? = nil do
      
      if time.is_a? TInteger || time.is_a? TFloat
        sleep(time.value)
      else
        sleep
      end

      TNil.new
    end

    def init_top_level(kernel : TModule)
      NativeLib.def_method(kernel, :exit, :mt_exit)
      NativeLib.def_method(kernel, :sleep, :mt_sleep)

      kernel
    end
  end
end
