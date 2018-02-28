module Myst
  class Interpreter
    NativeLib.method :mt_doc, MTValue, value : MTValue do
      self.__docs_for(value)
    end

    NativeLib.method :mt_exit, MTValue, status : Int64? do
      real_status = status.is_a?(Int64) ? status : 0

      exit(real_status.to_i32)
    end

    NativeLib.method :mt_sleep, MTValue, time : Int64 | Float64? = nil do
      if time.is_a?(Int64) || time.is_a?(Float64)
        sleep(time)
      else
        sleep
      end

      TNil.new
    end


    def init_top_level
      NativeLib.def_method(@kernel, :doc,   :mt_doc)
      NativeLib.def_method(@kernel, :exit,  :mt_exit)
      NativeLib.def_method(@kernel, :sleep, :mt_sleep)
    end
  end
end
