module Myst
  class Interpreter
    NativeLib.method :static_time_now, MTValue do
      seconds, nanoseconds = Crystal::System::Time.compute_utc_seconds_and_nanoseconds
      offset = Time.new(seconds: seconds, nanoseconds: nanoseconds, location: Time::Location.local).offset

      instance = NativeLib.instantiate(self, this.as(TType), [
        seconds + offset,
        nanoseconds.to_i64
      ] of MTValue)

      instance
    end

    NativeLib.method :time_to_s, TInstance, format : String? do
      crystal_time = to_crystal_time(this)

      if format
       crystal_time.to_s(format)
      else
       crystal_time.to_s("%Y-%m-%d %H:%M:%S")
      end
    end

    def init_time
      time_type = __make_type("Time", @kernel.scope)

      NativeLib.def_method(time_type, :now, :static_time_now)
      NativeLib.def_instance_method(time_type, :to_s,  :time_to_s)

      time_type
    end

    private def to_crystal_time(myst_time : TInstance)
      Time.new(
        seconds: myst_time.ivars["@seconds"].as(Int64),
        nanoseconds: myst_time.ivars["@nanoseconds"].as(Int64).to_i32,
        location: Time::Location::UTC
      )
    end
  end
end
