module Myst
  TList::METHODS["each"] = TFunctor.new([
    TNativeDef.new do |this, _args, block, itr|
      this = this.as(TList)
      this.elements.each do |elem|
        NativeLib.call_func(itr, block, elem)
      end
      this
    end
  ] of Callable)
end
