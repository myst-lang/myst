module Myst
  class Interpreter
    NativeLib.method :map_each, TMap do
      if block
        this.entries.each do |(key, val)|
          NativeLib.call_func(self, block, [key, val], nil)
        end
      end

      this
    end

    NativeLib.method :map_size, TMap do
      TInteger.new(this.entries.size.to_i64)
    end

    NativeLib.method :map_add, TMap, other : TMap do
      TMap.new(this.entries.merge(other.entries))
    end

    NativeLib.method :map_eq, TMap, other : MTValue do
      return TBoolean.new(false)  unless other.is_a?(TMap)
      return TBoolean.new(true)   if this == other
      return TBoolean.new(false)  if this.entries.size != other.entries.size

      # At this point, `this` and `other` must have the same number of keys,
      # meaning that if `other` contains all of the keys that `this` does, it
      # also cannot contain any extra keys, so it's only necessary to iterate
      # one of the two maps' keys.
      this.entries.keys.zip(other.entries.keys).each do |a_key, b_key|
        return TBoolean.new(false) unless NativeLib.call_func_by_name(self, a_key, "==", [b_key]).truthy?
        return TBoolean.new(false) unless NativeLib.call_func_by_name(self, this.entries[a_key], "==", [other.entries[b_key]]).truthy?
      end

      TBoolean.new(true)
    end

    NativeLib.method :map_not_eq, TMap, other : MTValue do
      return TBoolean.new(true)   unless other.is_a?(TMap)
      return TBoolean.new(false)  if this == other
      return TBoolean.new(true)   if this.entries.size != other.entries.size

      # At this point, `this` and `other` must have the same number of keys,
      # meaning that if `other` contains all of the keys that `this` does, it
      # also cannot contain any extra keys, so it's only necessary to iterate
      # one of the two maps' keys.
      this.entries.keys.zip(other.entries.keys).each do |a_key, b_key|
        return TBoolean.new(true) if NativeLib.call_func_by_name(self, a_key, "==", [b_key]).truthy?
        return TBoolean.new(true) if NativeLib.call_func_by_name(self, this.entries[a_key], "==", [other.entries[b_key]]).truthy?
      end

      TBoolean.new(true)
    end

    NativeLib.method :map_access, TMap, index : MTValue do
      this.entries[index]? || TNil.new
    end

    NativeLib.method :map_access_assign, TMap, index : MTValue, value : MTValue do
      this.entries[index] = value
    end

    NativeLib.method :map_proper_subset, TMap, other : TMap do
      return TBoolean.new(false)  unless other.is_a?(TMap)
      return TBoolean.new(false)  if this.entries.keys == other.entries.keys

      if (this.entries.keys - other.entries.keys).empty?
        TBoolean.new(true)
      else
        TBoolean.new(false)
      end
    end

    NativeLib.method :map_subset, TMap, other : TMap do
      return TBoolean.new(false)  unless other.is_a?(TMap)

      if (this.entries.keys - other.entries.keys).empty?
        TBoolean.new(true)
      else
        TBoolean.new(false)
      end
    end

    def init_map(kernel : TModule)
      map_type = TType.new("Map", kernel.scope)
      map_type.instance_scope["type"] = map_type

      NativeLib.def_instance_method(map_type, :each, :map_each)
      NativeLib.def_instance_method(map_type, :size, :map_size)
      NativeLib.def_instance_method(map_type, :+,    :map_add)
      NativeLib.def_instance_method(map_type, :==,   :map_eq)
      NativeLib.def_instance_method(map_type, :!=,   :map_not_eq)
      NativeLib.def_instance_method(map_type, :[],   :map_access)
      NativeLib.def_instance_method(map_type, :[]=,  :map_access_assign)
      NativeLib.def_instance_method(map_type, :<,    :map_proper_subset)
      NativeLib.def_instance_method(map_type, :<=,   :map_subset)

      map_type
    end
  end
end
