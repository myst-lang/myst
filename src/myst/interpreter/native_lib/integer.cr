module Myst
  INTEGER_TYPE.instance_scope["+"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TInteger)
      case arg
      when TInteger
        TInteger.new(this.value + arg.value)
      when TFloat
        TFloat.new(this.value + arg.value)
      else
        raise "invalid argument for Integer#+: #{arg.type.name}"
      end
    end
  ] of Callable)

  INTEGER_TYPE.instance_scope["-"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TInteger)
      case arg
      when TInteger
        TInteger.new(this.value - arg.value)
      when TFloat
        TFloat.new(this.value - arg.value)
      else
        raise "invalid argument for Integer#-: #{arg.type.name}"
      end
    end
  ] of Callable)

  INTEGER_TYPE.instance_scope["*"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TInteger)
      case arg
      when TInteger
        TInteger.new(this.value * arg.value)
      when TFloat
        TFloat.new(this.value * arg.value)
      else
        raise "invalid argument for Integer#*: #{arg.type.name}"
      end
    end
  ] of Callable)

  INTEGER_TYPE.instance_scope["/"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TInteger)
      case arg
      when TInteger
        raise "Division by zero" if arg.value == 0
        TInteger.new(this.value / arg.value)
      when TFloat
        raise "Division by zero" if arg.value == 0
        TFloat.new(this.value / arg.value)
      else
        raise "invalid argument for Integer#/: #{arg.type.name}"
      end
    end
  ] of Callable)

  INTEGER_TYPE.instance_scope["%"] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TInteger)
      case arg
      when TInteger
        raise "Division by zero" if arg.value == 0
        TInteger.new(this.value % arg.value)
      when TFloat
        raise "Division by zero" if arg.value == 0
        TFloat.new(this.value.to_f % arg.value)
      else
        raise "invalid argument for Integer#%: #{arg.type.name}"
      end
    end
  ] of Callable)

  INTEGER_TYPE.instance_scope["to_s"] = TFunctor.new([
    TNativeDef.new(0) do |this, _args, _block, _itr|
      this = this.as(TInteger)
      TString.new(this.value.to_s)
    end
  ] of Callable)


  INTEGER_TYPE.instance_scope["=="] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TInteger)
      case arg
      when TInteger, TFloat
        TBoolean.new(this.value == arg.value)
      else
        TBoolean.new(false)
      end
    end
  ] of Callable)

  INTEGER_TYPE.instance_scope["!="] = TFunctor.new([
    TNativeDef.new(1) do |this, (arg), _block, _itr|
      this = this.as(TInteger)
      case arg
      when TInteger, TFloat
        TBoolean.new(this.value != arg.value)
      else
        TBoolean.new(true)
      end
    end
  ] of Callable)
end
