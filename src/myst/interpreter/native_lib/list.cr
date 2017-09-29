module Myst
  TList::METHODS["each"] = TNativeFunctor.new do |this, _args, block, itr|
    this = this.as(TList)
    this.elements.each do |elem|
      NativeLib.call_func(itr, block, elem)
    end
    this
  end
end
