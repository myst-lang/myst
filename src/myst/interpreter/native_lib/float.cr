module Myst
  class Interpreter
    NativeLib.method :float_add, Float64, other : MTValue do
      case other
      when Int64, Float64
        this + other
      else
        __raise_runtime_error("invalid argument for Float#+: #{__typeof(other).name}")
      end
    end

    NativeLib.method :float_subtract, Float64, other : MTValue do
      case other
      when Int64, Float64
        this - other
      else
        __raise_runtime_error("invalid argument for Float#-: #{__typeof(other).name}")
      end
    end

    NativeLib.method :float_multiply, Float64, other : MTValue do
      case other
      when Int64, Float64
        this * other
      else
        __raise_runtime_error("invalid argument for Float#*: #{__typeof(other).name}")
      end
    end

    NativeLib.method :float_divide, Float64, other : MTValue do
      case other
      when Int64, Float64
        __raise_runtime_error("Division by zero") if other == 0
        this / other
      else
        __raise_runtime_error("invalid argument for Float#/: #{__typeof(other).name}")
      end
    end

    NativeLib.method :float_modulo, Float64, other : MTValue do
      case other
      when Int64, Float64
        __raise_runtime_error("Division by zero") if other == 0
        this % other
      else
        __raise_runtime_error("invalid argument for Float#%: #{__typeof(other).name}")
      end
    end

    NativeLib.method :float_to_i, Float64 do
      this.to_i64
    end

    NativeLib.method :float_round, Float64 do
      this.round
    end

    NativeLib.method :float_to_s, Float64 do
      this.to_s
    end

    NativeLib.method :float_eq, Float64, other : MTValue do
      this == other
    end

    NativeLib.method :float_not_eq, Float64, other : MTValue do
      this != other
    end

    NativeLib.method :float_negate, Float64 do
      -this
    end

    NativeLib.method :float_lt, Float64, other : MTValue do
      case other
      when Int64, Float64
        this < other
      else
        __raise_runtime_error("invalid argument for Float#<: #{__typeof(other).name}")
      end
    end

    NativeLib.method :float_lte, Float64, other : MTValue do
      case other
      when Int64, Float64
        this <= other
      else
        __raise_runtime_error("invalid argument for Float#<=: #{__typeof(other).name}")
      end
    end

    NativeLib.method :float_gt, Float64, other : MTValue do
      case other
      when Int64, Float64
        this > other
      else
        __raise_runtime_error("invalid argument for Float#>: #{__typeof(other).name}")
      end
    end

    NativeLib.method :float_gte, Float64, other : MTValue do
      case other
      when Int64, Float64
        this >= other
      else
        __raise_runtime_error("invalid argument for Float#>=: #{__typeof(other).name}")
      end
    end

    def init_float(kernel : TModule)
      float_type = TType.new("Float", kernel.scope)
      float_type.instance_scope["type"] = float_type

      NativeLib.def_instance_method(float_type, :+,       :float_add)
      NativeLib.def_instance_method(float_type, :-,       :float_subtract)
      NativeLib.def_instance_method(float_type, :*,       :float_multiply)
      NativeLib.def_instance_method(float_type, :/,       :float_divide)
      NativeLib.def_instance_method(float_type, :%,       :float_modulo)
      NativeLib.def_instance_method(float_type, :==,      :float_eq)
      NativeLib.def_instance_method(float_type, :!=,      :float_not_eq)
      NativeLib.def_instance_method(float_type, :to_i,    :float_to_i)
      NativeLib.def_instance_method(float_type, :round,   :float_round)
      NativeLib.def_instance_method(float_type, :to_s,    :float_to_s)
      NativeLib.def_instance_method(float_type, :negate,  :float_negate)
      NativeLib.def_instance_method(float_type, :<,       :float_lt)
      NativeLib.def_instance_method(float_type, :<=,      :float_lte)
      NativeLib.def_instance_method(float_type, :>,       :float_gt)
      NativeLib.def_instance_method(float_type, :>=,      :float_gte)

      float_type
    end
  end
end
