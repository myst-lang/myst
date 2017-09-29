module Myst
  TInteger::METHODS["+"] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TInteger)
    case arg
    when TInteger
      TInteger.new(this.value + arg.value)
    when TFloat
      TFloat.new(this.value + arg.value)
    else
      raise "invalid argument for Integer#+: #{arg.type_name}"
    end
  end

  TInteger::METHODS["to_s"] = TNativeFunctor.new do |this, _args, _block, _itr|
    this = this.as(TInteger)
    TString.new(this.value.to_s)
  end
end
