module Myst
  TSymbol::METHODS["to_s"] = TNativeFunctor.new do |this, _args, _block, _itr|
    this = this.as(TSymbol)
    TString.new(this.name)
  end
end
