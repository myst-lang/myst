module Myst
  TSymbol::METHODS["to_s"] = TNativeFunctor.new do |this, _args, _block, _itr|
    this = this.as(TSymbol)
    TString.new(this.name)
  end


  TSymbol::METHODS["=="] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TSymbol)
    case arg
    when TSymbol
      TBoolean.new(this.value == arg.value)
    else
      TBoolean.new(false)
    end
  end

  TSymbol::METHODS["!="] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TSymbol)
    case arg
    when TSymbol
      TBoolean.new(this.value != arg.value)
    else
      TBoolean.new(true)
    end
  end
end
