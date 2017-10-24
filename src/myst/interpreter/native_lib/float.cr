module Myst
  class Interpreter
    def init_float
      float_type = TType.new("Float")
      float_type.instance_scope["+"] = TFunctor.new([
        TNativeDef.new(1) do |this, (arg), _block, _itr|
          this = this.as(TFloat)
          case arg
          when TInteger, TFloat
            TFloat.new(this.value + arg.value)
          else
            raise "invalid argument for Float#+: #{__typeof(arg).name}"
          end
        end
      ] of Callable)

      float_type.instance_scope["-"] = TFunctor.new([
        TNativeDef.new(1) do |this, (arg), _block, _itr|
          this = this.as(TFloat)
          case arg
          when TInteger, TFloat
            TFloat.new(this.value - arg.value)
          else
            raise "invalid argument for Float#-: #{__typeof(arg).name}"
          end
        end
      ] of Callable)

      float_type.instance_scope["*"] = TFunctor.new([
        TNativeDef.new(1) do |this, (arg), _block, _itr|
          this = this.as(TFloat)
          case arg
          when TInteger, TFloat
            TFloat.new(this.value * arg.value)
          else
            raise "invalid argument for Float#*: #{__typeof(arg).name}"
          end
        end
      ] of Callable)

      float_type.instance_scope["/"] = TFunctor.new([
        TNativeDef.new(1) do |this, (arg), _block, _itr|
          this = this.as(TFloat)
          case arg
          when TInteger, TFloat
            raise "Division by zero" if arg.value == 0
            TFloat.new(this.value / arg.value)
          else
            raise "invalid argument for Float#/: #{__typeof(arg).name}"
          end
        end
      ] of Callable)

      float_type.instance_scope["%"] = TFunctor.new([
        TNativeDef.new(1) do |this, (arg), _block, _itr|
          this = this.as(TFloat)
          case arg
          when TInteger, TFloat
            raise "Division by zero" if arg.value == 0
            TFloat.new(this.value % arg.value)
          else
            raise "invalid argument for Float#%: #{__typeof(arg).name}"
          end
        end
      ] of Callable)

      float_type.instance_scope["to_s"] = TFunctor.new([
        TNativeDef.new(0) do |this, _args, _block, _itr|
          this = this.as(TFloat)
          TString.new(this.value.to_s)
        end
      ] of Callable)

      float_type.instance_scope["=="] = TFunctor.new([
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

      float_type.instance_scope["!="] = TFunctor.new([
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


      @kernel.scope["Float"] = float_type
    end
  end
end
