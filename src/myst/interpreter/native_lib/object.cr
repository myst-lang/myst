module Myst
  class Interpreter
    NativeLib.method :obj_to_s, TInstance do
      this.to_s
    end

    NativeLib.method :obj_eq, TInstance, other : MTValue do
      case other
      when TInstance
        this == other
      else
        false
      end
    end

    NativeLib.method :obj_not_eq, TInstance, other : MTValue do
      case other
      when TInstance
        this != other
      else
        false
      end
    end


    def init_base_object
      # These methods are intentionally copied from `Type` to provide the
      # same behavior without having to circularly have `Type` be a superclass
      # of `Object`.
      NativeLib.def_method(@base_object, :to_s,       :static_type_to_s)
      NativeLib.def_method(@base_object, :==,         :static_type_eq)
      NativeLib.def_method(@base_object, :!=,         :static_type_not_eq)
      NativeLib.def_method(@base_object, :ancestors,  :static_type_ancestors)

      NativeLib.def_instance_method(@base_object, :to_s,    :obj_to_s)
      NativeLib.def_instance_method(@base_object, :==,      :obj_eq)
      NativeLib.def_instance_method(@base_object, :!=,      :obj_not_eq)

      @base_object
    end
  end
end
