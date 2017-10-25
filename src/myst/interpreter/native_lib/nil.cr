module Myst
  class Interpreter
    NativeLib.method :nil_to_s, TNil do
      TString.new("")
    end

    NativeLib.method :nil_eq, TNil, other : Value do
      case other
      when TNil
        TBoolean.new(true)
      else
        TBoolean.new(false)
      end
    end

    NativeLib.method :nil_not_eq, TNil, other : Value do
      case other
      when TNil
        TBoolean.new(false)
      else
        TBoolean.new(true)
      end
    end


    def init_nil(root_scope : Scope)
      nil_type = TType.new("Nil", root_scope)

      NativeLib.def_instance_method(nil_type, :to_s,  :nil_to_s)
      NativeLib.def_instance_method(nil_type, :==,    :nil_eq)
      NativeLib.def_instance_method(nil_type, :!=,    :nil_not_eq)

      nil_type
    end
  end
end
