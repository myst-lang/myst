module Myst
  TList::SCOPE["each"] = TFunctor.new([
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
end
