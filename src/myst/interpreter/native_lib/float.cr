module Myst
  class Interpreter
    NativeLib.method :float_add, TFloat, other : Value do
      case other
      when TInteger, TFloat
        TFloat.new(this.value + other.value)
      else
        raise "invalid argument for Float#+: #{__typeof(other).name}"
      end
    end

    NativeLib.method :float_subtract, TFloat, other : Value do
      case other
      when TInteger, TFloat
        TFloat.new(this.value - other.value)
      else
        raise "invalid argument for Float#-: #{__typeof(other).name}"
      end
    end

    NativeLib.method :float_multiply, TFloat, other : Value do
      case other
      when TInteger, TFloat
        TFloat.new(this.value * other.value)
      else
        raise "invalid argument for Float#*: #{__typeof(other).name}"
      end
    end

    NativeLib.method :float_divide, TFloat, other : Value do
      case other
      when TInteger, TFloat
        raise "Division by zero" if other.value == 0
        TFloat.new(this.value / other.value)
      else
        raise "invalid argument for Float#/: #{__typeof(other).name}"
      end
    end

    NativeLib.method :float_modulo, TFloat, other : Value do
      case other
      when TInteger, TFloat
        raise "Division by zero" if other.value == 0
        TFloat.new(this.value % other.value)
      else
        raise "invalid argument for Float#%: #{__typeof(other).name}"
      end
    end

    NativeLib.method :float_to_s, TFloat do
      TString.new(this.value.to_s)
    end

    NativeLib.method :float_eq, TFloat, other : Value do
      case other
      when TFloat, TInteger
        TBoolean.new(this.value == other.value)
      else
        TBoolean.new(false)
      end
    end

    NativeLib.method :float_not_eq, TFloat, other : Value do
      case other
      when TFloat, TInteger
        TBoolean.new(this.value != other.value)
      else
        TBoolean.new(true)
      end
    end


    def init_float(kernel : TModule)
      float_type = TType.new("Float", kernel.scope)
      float_type.instance_scope["type"] = float_type

      NativeLib.def_instance_method(float_type, :+,     :float_add)
      NativeLib.def_instance_method(float_type, :-,     :float_subtract)
      NativeLib.def_instance_method(float_type, :*,     :float_multiply)
      NativeLib.def_instance_method(float_type, :/,     :float_divide)
      NativeLib.def_instance_method(float_type, :%,     :float_modulo)
      NativeLib.def_instance_method(float_type, :==,    :float_eq)
      NativeLib.def_instance_method(float_type, :!=,    :float_not_eq)
      NativeLib.def_instance_method(float_type, :to_s,  :float_to_s)

      float_type
    end
  end
end
