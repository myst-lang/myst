module Myst
  TFloat::METHODS["+"] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TFloat)
    case arg
    when TInteger, TFloat
      TFloat.new(this.value + arg.value)
    else
      raise "invalid argument for Float#+: #{arg.type_name}"
    end
  end

  TFloat::METHODS["-"] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TFloat)
    case arg
    when TInteger, TFloat
      TFloat.new(this.value - arg.value)
    else
      raise "invalid argument for Float#-: #{arg.type_name}"
    end
  end

  TFloat::METHODS["*"] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TFloat)
    case arg
    when TInteger, TFloat
      TFloat.new(this.value * arg.value)
    else
      raise "invalid argument for Float#*: #{arg.type_name}"
    end
  end

  TFloat::METHODS["/"] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TFloat)
    case arg
    when TInteger, TFloat
      raise "Division by zero" if arg.value == 0
      TFloat.new(this.value / arg.value)
    else
      raise "invalid argument for Float#/: #{arg.type_name}"
    end
  end

  TFloat::METHODS["%"] = TNativeFunctor.new do |this, (arg), _block, _itr|
    this = this.as(TFloat)
    case arg
    when TInteger, TFloat
      raise "Division by zero" if arg.value == 0
      TFloat.new(this.value % arg.value)
    else
      raise "invalid argument for Float#%: #{arg.type_name}"
    end
  end

  TFloat::METHODS["to_s"] = TNativeFunctor.new do |this, _args, _block, _itr|
    this = this.as(TFloat)
    TString.new(this.value.to_s)
  end
end
