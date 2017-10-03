module Myst
  TNil::METHODS["to_s"] = TNativeFunctor.new do |_this, _args, _block, _itr|
    TString.new("nil")
  end

  TNil::METHODS["=="] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TNil)
    case arg
    when TNil
      TBoolean.new(true)
    else
      TBoolean.new(false)
    end
  end

  TNil::METHODS["!="] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TNil)
    case arg
    when TNil
      TBoolean.new(false)
    else
      TBoolean.new(true)
    end
  end
end
