module Myst
  class Interpreter
    NativeLib.method :static_time_now, Value do
      seconds, nanoseconds = Crystal::System::Time.compute_utc_seconds_and_nanoseconds
      offset = Crystal::System::Time.compute_utc_offset(seconds)
      
      instance = NativeLib.instantiate(self, this.as(TType), [
        TInteger.new(seconds + offset), 
        TInteger.new(nanoseconds.to_i64)
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

      NativeLib.def_method(time_type, :now, :static_time_now)
      NativeLib.def_instance_method(time_type, :to_s,  :time_to_s)

      time_type
    end

    private def to_crystal_time(myst_time : TInstance)
      Time.new(
        seconds: myst_time.ivars["@seconds"].as(TInteger).value,
        nanoseconds: myst_time.ivars["@nanoseconds"].as(TInteger).value.to_i32,
        kind: Time::Kind::Unspecified
      )
    end
  end
end
