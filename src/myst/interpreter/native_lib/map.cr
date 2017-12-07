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

    def init_map(kernel : TModule)
      map_type = TType.new("Map", kernel.scope)
      map_type.instance_scope["type"] = map_type

      NativeLib.def_instance_method(map_type, :each, :map_each)
      NativeLib.def_instance_method(map_type, :size, :map_size)
      NativeLib.def_instance_method(map_type, :+, :map_add)

      map_type
    end
  end
end
