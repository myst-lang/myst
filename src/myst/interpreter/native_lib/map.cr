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


    def init_map(root_scope : Scope)
      map_type = TType.new("Map", root_scope)
      map_type.instance_scope["type"] = map_type

      NativeLib.def_instance_method(map_type, :each, :map_each)

      map_type
    end
  end
end
