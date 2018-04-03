module Myst
  class Interpreter
    NativeLib.method :int_add, Int64, other : MTValue do
      case other
      when Int64, Float64
        this + other
      else
        __raise_runtime_error("invalid argument for Integer#+: #{__typeof(other).name}")
      end
    end

    NativeLib.method :int_subtract, Int64, other : MTValue do
      case other
      when Int64, Float64
        this - other
      else
        __raise_runtime_error("invalid argument for Integer#-: #{__typeof(other).name}")
      end
    end

    NativeLib.method :int_multiply, Int64, other : MTValue do
      case other
      when Int64, Float64
        this * other
      else
        __raise_runtime_error("invalid argument for Integer#*: #{__typeof(other).name}")
      end
    end

    NativeLib.method :int_divide, Int64, other : MTValue do
      case other
      when Int64, Float64
        __raise_runtime_error("Division by zero") if other == 0
        this / other
      else
        __raise_runtime_error("invalid argument for Integer#/: #{__typeof(other).name}")
      end
    end

    NativeLib.method :int_modulo, Int64, other : MTValue do
      case other
      when Int64
        __raise_runtime_error("Division by zero") if other == 0
        this % other
      when Float64
        __raise_runtime_error("Division by zero") if other == 0
        this.to_f % other
      else
        __raise_runtime_error("invalid argument for Integer#%: #{__typeof(other).name}")
      end
    end

    NativeLib.method :int_to_f, Int64 do
      this.to_f64
    end

    NativeLib.method :int_to_s, Int64 do
      this.to_s
    end

    NativeLib.method :int_eq, Int64, other : MTValue do
      this == other
    end

    NativeLib.method :int_not_eq, Int64, other : MTValue do
      this != other
    end

    NativeLib.method :int_negate, Int64 do
      -this
    end

    NativeLib.method :int_lt, Int64, other : MTValue do
      case other
      when Int64, Float64
        this < other
      else
        __raise_runtime_error("invalid argument for Integer#<: #{__typeof(other).name}")
      end
    end

    NativeLib.method :int_lte, Int64, other : MTValue do
      case other
      when Int64, Float64
        this <= other
      else
        __raise_runtime_error("invalid argument for Integer#<=: #{__typeof(other).name}")
      end
    end

    NativeLib.method :int_gt, Int64, other : MTValue do
      case other
      when Int64, Float64
        this > other
      else
        __raise_runtime_error("invalid argument for Integer#>: #{__typeof(other).name}")
      end
    end

    NativeLib.method :int_gte, Int64, other : MTValue do
      case other
      when Int64, Float64
        this >= other
      else
        __raise_runtime_error("invalid argument for Integer#>=: #{__typeof(other).name}")
      end
    end

    def init_integer
      integer_type = __make_type("Integer", @kernel.scope)

      NativeLib.def_instance_method(integer_type, :+,     :int_add)
      NativeLib.def_instance_method(integer_type, :-,     :int_subtract)
      NativeLib.def_instance_method(integer_type, :*,     :int_multiply)
      NativeLib.def_instance_method(integer_type, :/,     :int_divide)
      NativeLib.def_instance_method(integer_type, :%,     :int_modulo)
      NativeLib.def_instance_method(integer_type, :==,    :int_eq)
      NativeLib.def_instance_method(integer_type, :!=,    :int_not_eq)
      NativeLib.def_instance_method(integer_type, :to_f,  :int_to_f)
      NativeLib.def_instance_method(integer_type, :to_s,  :int_to_s)
      NativeLib.def_instance_method(integer_type, :negate,:int_negate)
      NativeLib.def_instance_method(integer_type, :<,     :int_lt)
      NativeLib.def_instance_method(integer_type, :<=,    :int_lte)
      NativeLib.def_instance_method(integer_type, :>,     :int_gt)
      NativeLib.def_instance_method(integer_type, :>=,    :int_gte)

      integer_type
    end
  end
end
