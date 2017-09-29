module Myst
  TString::METHODS["+"] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TString)
    case arg
    when TString
      TString.new(this.value + arg.value)
    else
      raise "invalid argument for String#+: #{arg.type_name}"
    end
  end

  TString::METHODS["*"] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TString)
    case arg
    when TInteger
      # String multiplication repeats `this` `arg` times.
      TString.new(this.value * arg.value)
    else
      raise "invalid argument for String#*: #{arg.type_name}"
    end
  end

  TString::METHODS["to_s"] = TNativeFunctor.new do |this, _args, _block, _itr|
    this.as(TString)
  end
end
