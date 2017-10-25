module Myst
  class Interpreter
    NativeLib.method :bool_to_s, TBoolean do
      TString.new(this.value ? "true" : "false")
    end

    NativeLib.method :bool_eq, TBoolean, other : Value do
      case other
      when TBoolean
        TBoolean.new(this.value == other.value)
      else
        TBoolean.new(false)
      end
    end

    NativeLib.method :bool_not_eq, TBoolean, other : Value do
      case other
      when TBoolean
        TBoolean.new(this.value != other.value)
      else
        TBoolean.new(true)
      end
    end


    def init_boolean(root_scope : Scope)
      boolean_type = TType.new("Boolean", root_scope)

      NativeLib.def_instance_method(boolean_type, :to_s,  :bool_to_s)
      NativeLib.def_instance_method(boolean_type, :==,    :bool_eq)
      NativeLib.def_instance_method(boolean_type, :!=,    :bool_not_eq)

      boolean_type
    end
  end
end
