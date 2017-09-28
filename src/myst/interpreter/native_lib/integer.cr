module Myst
  TInteger::METHODS["+"] = TNativeFunctor.new do |this, args, _block_arg, itr|
    this = this.as(TInteger)
    case arg = args[0]
    when TInteger
      TInteger.new(this.value + arg.value)
    when TFloat
      TFloat.new(this.value + arg.value)
    else
      raise "invalid argument for Integer#+: #{arg.type_name}"
    end
  end
end
