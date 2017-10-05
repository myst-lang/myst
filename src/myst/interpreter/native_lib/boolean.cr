module Myst
  TBoolean::METHODS["to_s"] = TFunctor.new([
    TNativeDef.new do |this, _args, _block, _itr|
      TString.new(this.as(TBoolean).value ? "true" : "false")
    end
  ] of Callable)

  TBoolean::METHODS["=="] = TFunctor.new([
    TNativeDef.new do |this, (arg), _block, _itr|
      this = this.as(TBoolean)
      case arg
      when TBoolean
        TBoolean.new(this.value == arg.value)
      else
        TBoolean.new(false)
      end
    end
  ] of Callable)

  TBoolean::METHODS["!="] = TFunctor.new([
    TNativeDef.new do |this, (arg), _block, _itr|
      this = this.as(TBoolean)
      case arg
      when TBoolean
        TBoolean.new(this.value != arg.value)
      else
        TBoolean.new(true)
      end
    end
  ] of Callable)
end
