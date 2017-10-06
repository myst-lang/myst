module Myst
  TSymbol::METHODS["to_s"] = TFunctor.new([
    TNativeDef.new(0) do |this, _args, _block, _itr|
      this = this.as(TSymbol)
      TString.new(this.name)
    end
    ] of Callable)


  TSymbol::METHODS["=="] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TSymbol)
      case arg
      when TSymbol
        TBoolean.new(this.value == arg.value)
      else
        TBoolean.new(false)
      end
    end
  ] of Callable)

  TSymbol::METHODS["!="] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TSymbol)
      case arg
      when TSymbol
        TBoolean.new(this.value != arg.value)
      else
        TBoolean.new(true)
      end
    end
  ] of Callable)
end
