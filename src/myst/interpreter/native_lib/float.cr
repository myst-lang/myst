module Myst
  TFloat::METHODS["+"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TFloat)
      case arg
      when TInteger, TFloat
        TFloat.new(this.value + arg.value)
      else
        raise "invalid argument for Float#+: #{arg.type_name}"
      end
    end
  ] of Callable)

  TFloat::METHODS["-"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TFloat)
      case arg
      when TInteger, TFloat
        TFloat.new(this.value - arg.value)
      else
        raise "invalid argument for Float#-: #{arg.type_name}"
      end
    end
  ] of Callable)

  TFloat::METHODS["*"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TFloat)
      case arg
      when TInteger, TFloat
        TFloat.new(this.value * arg.value)
      else
        raise "invalid argument for Float#*: #{arg.type_name}"
      end
    end
  ] of Callable)

  TFloat::METHODS["/"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TFloat)
      case arg
      when TInteger, TFloat
        raise "Division by zero" if arg.value == 0
        TFloat.new(this.value / arg.value)
      else
        raise "invalid argument for Float#/: #{arg.type_name}"
      end
    end
  ] of Callable)

  TFloat::METHODS["%"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TFloat)
      case arg
      when TInteger, TFloat
        raise "Division by zero" if arg.value == 0
        TFloat.new(this.value % arg.value)
      else
        raise "invalid argument for Float#%: #{arg.type_name}"
      end
    end
  ] of Callable)

  TFloat::METHODS["to_s"] = TFunctor.new([
    TNativeDef.new(0) do |this, _args, _block, _itr|
      this = this.as(TFloat)
      TString.new(this.value.to_s)
    end
  ] of Callable)

  TFloat::METHODS["=="] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TFloat)
      case arg
      when TFloat, TInteger
        TBoolean.new(this.value == arg.value)
      else
        TBoolean.new(false)
      end
    end
  ] of Callable)

  TFloat::METHODS["!="] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TFloat)
      case arg
      when TFloat, TInteger
        TBoolean.new(this.value != arg.value)
      else
        TBoolean.new(true)
      end
    end
  ] of Callable)
end
