module Myst
  TString::METHODS["+"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TString)
      case arg
      when TString
        TString.new(this.value + arg.value)
      else
        raise "invalid argument for String#+: #{arg.type_name}"
      end
    end
  ] of Callable)

  TString::METHODS["*"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TString)
      case arg
      when TInteger
        # String multiplication repeats `this` `arg` times.
        TString.new(this.value * arg.value)
      else
        raise "invalid argument for String#*: #{arg.type_name}"
      end
    end
  ] of Callable)

  TString::METHODS["to_s"] = TFunctor.new([
    TNativeDef.new(1) do |this, _args, _block, _itr|
      this.as(TString)
    end
  ] of Callable)

  TString::METHODS["=="] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TString)
      case arg
      when TString
        TBoolean.new(this.value == arg.value)
      else
        TBoolean.new(false)
      end
    end
  ] of Callable)

  TString::METHODS["!="] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TString)
      case arg
      when TString
        TBoolean.new(this.value != arg.value)
      else
        TBoolean.new(true)
      end
    end
  ] of Callable)
end
