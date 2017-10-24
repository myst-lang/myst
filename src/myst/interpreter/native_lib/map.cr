module Myst
  class Interpreter
    def init_map(root_scope : Scope)
      map_type = TType.new("Map", root_scope)

      map_type.instance_scope["each"] = TFunctor.new([
        TNativeDef.new(0) do |this, _args, block, itr|
          this = this.as(TMap)

          if block
            this.entries.each do |(key, val)|
              NativeLib.call_func(itr, block, [key, val], nil)
            end
          end

          this
        end
      ] of Callable)

      map_type
    end
  end
end
