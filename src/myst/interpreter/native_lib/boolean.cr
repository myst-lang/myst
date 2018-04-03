module Myst
  class Interpreter
    NativeLib.method :bool_to_s, Bool do
      this.to_s
    end

    NativeLib.method :bool_eq, Bool, other : MTValue do
      this == other
    end

    NativeLib.method :bool_not_eq, Bool, other : MTValue do
      this != other
    end

    def init_boolean
      boolean_type = __make_type("Boolean", @kernel.scope)

      NativeLib.def_instance_method(boolean_type, :to_s,  :bool_to_s)
      NativeLib.def_instance_method(boolean_type, :==,    :bool_eq)
      NativeLib.def_instance_method(boolean_type, :!=,    :bool_not_eq)

      boolean_type
    end
  end
end
