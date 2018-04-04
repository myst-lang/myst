module Myst
  class Interpreter
    NativeLib.method :static_type_to_s, TType do
      this.name
    end

    NativeLib.method :static_type_eq, TType, other : MTValue do
      case other
      when TType
        this == other
      else
        false
      end
    end

    NativeLib.method :static_type_not_eq, TType, other : MTValue do
      case other
      when TType
        this != other
      else
        true
      end
    end

    NativeLib.method :static_type_ancestors, TType do
      TList.new(this.ancestors.map(&.as(MTValue)))
    end

    NativeLib.method :inst_to_s, TInstance do
      this.to_s
    end


    def init_base_type
      NativeLib.def_method(@base_type, :to_s,       :static_type_to_s)
      NativeLib.def_method(@base_type, :==,         :static_type_eq)
      NativeLib.def_method(@base_type, :!=,         :static_type_not_eq)
      NativeLib.def_method(@base_type, :ancestors,  :static_type_ancestors)

      NativeLib.def_instance_method(@base_type, :to_s,        :inst_to_s)

      @base_type
    end
  end
end
