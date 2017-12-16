module Myst
  class Interpreter
    NativeLib.method :list_each, TList do
      if block
        this.elements.each do |elem|
          NativeLib.call_func(self, block, [elem], nil)
        end
      end

      this
    end

    NativeLib.method :list_size, TList do
      TInteger.new(this.elements.size.to_i64)
    end

    NativeLib.method :list_splat, TList do
      this
    end

    NativeLib.method :list_eq, TList, other : Value do
      return TBoolean.new(false)  unless other.is_a?(TList)
      return TBoolean.new(true)   if this == other
      return TBoolean.new(false)  if this.elements.size != other.elements.size

      this.elements.zip(other.elements).each do |a, b|
        return TBoolean.new(false) unless NativeLib.call_func_by_name(self, a, "==", [b])
      end

      TBoolean.new(true)
    end

    NativeLib.method :list_add, TList, other : TList do
      TList.new(this.elements + other.elements)
    end

    NativeLib.method :list_access, TList, index : TInteger do
      if element = this.elements[index.value]?
        element
      else
        TNil.new
      end
    end

    NativeLib.method :list_access_assign, TList, index : TInteger, value : Value do
      this.ensure_capacity(index.value + 1)
      this.elements[index.value] = value
    end

    NativeLib.method :list_minus, TList, other : TList do
      TList.new(this.elements - other.elements)
    end

    NativeLib.method :list_proper_subset, TList, other : TList do
      return TBoolean.new(false)  unless other.is_a?(TList)
      return TBoolean.new(false)  if this == other
      
      if (this.elements - other.elements).empty?
        TBoolean.new(true)
      else
        TBoolean.new(false)
      end
    end

    NativeLib.method :list_subset, TList, other : TList do
      return TBoolean.new(false)  unless other.is_a?(TList)
      
      if (this.elements - other.elements).empty?
        TBoolean.new(true)
      else
        TBoolean.new(false)
      end
    end

    def init_list(kernel : TModule)
      list_type = TType.new("List", kernel.scope)
      list_type.instance_scope["type"] = list_type

      NativeLib.def_instance_method(list_type, :each, :list_each)
      NativeLib.def_instance_method(list_type, :size, :list_size)
      NativeLib.def_instance_method(list_type, :==,   :list_eq)
      NativeLib.def_instance_method(list_type, :+,    :list_add)
      NativeLib.def_instance_method(list_type, :*,    :list_splat)
      NativeLib.def_instance_method(list_type, :[],   :list_access)
      NativeLib.def_instance_method(list_type, :[]=,  :list_access_assign)
      NativeLib.def_instance_method(list_type, :-,    :list_minus)
      NativeLib.def_instance_method(list_type, :<,    :list_proper_subset)
      NativeLib.def_instance_method(list_type, :<=,   :list_subset)

      list_type
    end
  end
end
