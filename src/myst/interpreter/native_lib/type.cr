module Myst
  class Interpreter
    NativeLib.method :type_to_s, TType do
      this.name
    end

    NativeLib.method :type_eq, TType, other : MTValue do
      case other
      when TType
        this == other
      else
        false
      end
    end

    NativeLib.method :type_not_eq, TType, other : MTValue do
      case other
      when TType
        this != other
      else
        true
      end
    end


    def init_base_type
      NativeLib.def_method(@base_type, :to_s,  :type_to_s)
      NativeLib.def_method(@base_type, :==,    :type_eq)
      NativeLib.def_method(@base_type, :!=,    :type_not_eq)

      @base_type
    end
  end
end
