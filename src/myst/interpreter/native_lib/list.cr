module Myst
  class Interpreter
    def init_list(root_scope : Scope)
      list_type = TType.new("List", root_scope)

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

      list_type.instance_scope["+"] = TFunctor.new([
        TNativeDef.new(1) do |this, (other), block, itr|
          this = this.as(TList)
          other = other.as(TList)
          TList.new(this.elements + other.elements)
        end
      ] of Callable)

      list_type
    end
  end
end
