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

    NativeLib.method :list_eq, TList, other : MTValue do
      return TBoolean.new(false)  unless other.is_a?(TList)
      return TBoolean.new(true)   if this == other
      return TBoolean.new(false)  if this.elements.size != other.elements.size

      this.elements.zip(other.elements).each do |a, b|
        return TBoolean.new(false) unless NativeLib.call_func_by_name(self, a, "==", [b]).truthy?
      end

      TBoolean.new(true)
    end

    NativeLib.method :list_not_eq, TList, other : MTValue do
      return TBoolean.new(true)   unless other.is_a?(TList)
      return TBoolean.new(false)  if this == other
      return TBoolean.new(true)   if this.elements.size != other.elements.size

      this.elements.zip(other.elements).each do |a, b|
        return TBoolean.new(true) if NativeLib.call_func_by_name(self, a, "==", [b]).truthy?
      end

      TBoolean.new(false)
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

    NativeLib.method :list_access_assign, TList, index : TInteger, value : MTValue do
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

    NativeLib.method :list_push, TList do
      unless __args.size.zero?
        __args.each { |arg| this.elements.push(arg) }
      end
      this
    end

    NativeLib.method :list_pop, TList do
      if value = this.elements.pop?
        value
      else
        TNil.new
      end
    end

    NativeLib.method :list_unshift, TList do
      unless __args.size.zero?
        __args.reverse_each { |arg| this.elements.unshift(arg) }
      end
      this
    end

    NativeLib.method :list_shift, TList do
      if value = this.elements.shift?
        value
      else
        TNil.new
      end
    end

    def init_list(kernel : TModule)
      list_type = TType.new("List", kernel.scope)
      list_type.instance_scope["type"] = list_type

      NativeLib.def_instance_method(list_type, :each,    :list_each)
      NativeLib.def_instance_method(list_type, :size,    :list_size)
      NativeLib.def_instance_method(list_type, :==,      :list_eq)
      NativeLib.def_instance_method(list_type, :!=,      :list_not_eq)
      NativeLib.def_instance_method(list_type, :+,       :list_add)
      NativeLib.def_instance_method(list_type, :*,       :list_splat)
      NativeLib.def_instance_method(list_type, :[],      :list_access)
      NativeLib.def_instance_method(list_type, :[]=,     :list_access_assign)
      NativeLib.def_instance_method(list_type, :-,       :list_minus)
      NativeLib.def_instance_method(list_type, :<,       :list_proper_subset)
      NativeLib.def_instance_method(list_type, :<=,      :list_subset)
      NativeLib.def_instance_method(list_type, :push,    :list_push)
      NativeLib.def_instance_method(list_type, :pop,     :list_pop)
      NativeLib.def_instance_method(list_type, :unshift, :list_unshift)
      NativeLib.def_instance_method(list_type, :shift,   :list_shift)

      list_type
    end
  end
end
