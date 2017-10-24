module Myst
  class Interpreter
    def init_list
      list_type = TType.new("List")
      list_type.instance_scope["each"] = TFunctor.new([
        TNativeDef.new(0) do |this, _args, block, itr|
          this = this.as(TList)

          if block
            this.elements.each do |elem|
              NativeLib.call_func(itr, block, [elem], nil)
            end
          end

          this
        end
      ] of Callable)

      @kernel.scope["List"] = list_type
    end
  end
end
