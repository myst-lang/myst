module Myst
  class Interpreter
    NativeLib.method :static_time_now, Value do
      t = Time.now
      
      instance = NativeLib.instantiate(self, this.as(TType), [
        TInteger.new(t.year.to_i64), 
        TInteger.new(t.month.to_i64), 
        TInteger.new(t.day.to_i64), 
        TInteger.new(t.hour.to_i64), 
        TInteger.new(t.minute.to_i64), 
        TInteger.new(t.second.to_i64)
      ] of Value)

      instance
    end

    NativeLib.method :time_to_s, TInstance, format : TString? do
      crystal_time = to_crystal_time(this)

      if format
       TString.new(crystal_time.to_s(format.value))
      else
       TString.new(crystal_time.to_s)
      end
    end

    def init_time(kernel : TModule)
      time_type = TType.new("Time", kernel.scope)
      time_type.instance_scope["type"] = time_type

      NativeLib.def_method(time_type, :now,  :static_time_now)
      NativeLib.def_instance_method(time_type, :to_s,  :time_to_s)

      time_type
    end

    private def to_crystal_time(myst_time : TInstance)
      Time.new(
        myst_time.ivars["@year"].as(TInteger).value,
        myst_time.ivars["@month"].as(TInteger).value,
        myst_time.ivars["@day"].as(TInteger).value,
        myst_time.ivars["@hour"].as(TInteger).value,
        myst_time.ivars["@minute"].as(TInteger).value,
        myst_time.ivars["@second"].as(TInteger).value
      )
    end
  end
end
