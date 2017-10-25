module Myst
  class Interpreter
    NativeLib.method :string_add, TString, other : Value do
      case other
      when TString
        TString.new(this.value + other.value)
      else
        raise "invalid argument for String#+: #{__typeof(other).name}"
      end
    end

    NativeLib.method :string_multiply, TString, other : Value do
      case other
      when TInteger
        # String multiplication repeats `this` `arg` times.
        TString.new(this.value * other.value)
      else
        raise "invalid argument for String#*: #{__typeof(other).name}"
      end
    end

    NativeLib.method :string_to_s, TString do
      this.as(TString)
    end

    NativeLib.method :string_eq, TString, other : Value do
      case other
      when TString
        TBoolean.new(this.value == other.value)
      else
        TBoolean.new(false)
      end
    end

    NativeLib.method :string_not_eq, TString, other : Value do
      case other
      when TString
        TBoolean.new(this.value != other.value)
      else
        TBoolean.new(true)
      end
    end


    def init_string(root_scope : Scope)
      string_type = TType.new("String", root_scope)

      NativeLib.def_instance_method(string_type, :+,     :string_add)
      NativeLib.def_instance_method(string_type, :*,     :string_multiply)
      NativeLib.def_instance_method(string_type, :to_s,  :string_to_s)
      NativeLib.def_instance_method(string_type, :==,    :string_eq)
      NativeLib.def_instance_method(string_type, :!=,    :string_not_eq)

      string_type
    end
  end
end
