module Myst
  TBoolean::METHODS["to_s"] = TNativeFunctor.new do |this, _args, _block, _itr|
    TString.new(this.as(TBoolean).value ? "true" : "false")
  end

  TBoolean::METHODS["=="] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TBoolean)
    case arg
    when TBoolean
      TBoolean.new(this.value == arg.value)
    else
      TBoolean.new(false)
    end
  end

  TBoolean::METHODS["!="] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TBoolean)
    case arg
    when TBoolean
      TBoolean.new(this.value != arg.value)
    else
      TBoolean.new(true)
    end
  end
end
