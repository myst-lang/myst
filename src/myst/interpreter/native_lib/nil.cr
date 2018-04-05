module Myst
  class Interpreter
    NativeLib.method :nil_to_s, TNil do
      ""
    end

    NativeLib.method :nil_eq, TNil, other : MTValue do
      case other
      when TNil
        true
      else
        false
      end
    end

    NativeLib.method :nil_not_eq, TNil, other : MTValue do
      case other
      when TNil
        false
      else
        true
      end
    end


    def init_nil
      nil_type = __make_type("Nil", @kernel.scope)

      NativeLib.def_instance_method(nil_type, :to_s,  :nil_to_s)
      NativeLib.def_instance_method(nil_type, :==,    :nil_eq)
      NativeLib.def_instance_method(nil_type, :!=,    :nil_not_eq)

      nil_type
    end
  end
end
