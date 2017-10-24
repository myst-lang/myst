module Myst
  class Interpreter
    def init_map
      map_type = TType.new("Map")

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

      @kernel.scope["Map"] = map_type
    end
  end
end
