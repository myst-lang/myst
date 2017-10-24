module Myst
  class Interpreter
    def init_symbol
      symbol_type = TType.new("Symbol")
      symbol_type.instance_scope["to_s"] = TFunctor.new([
        TNativeDef.new(0) do |this, _args, _block, _itr|
          this = this.as(TSymbol)
          TString.new(this.name)
        end
        ] of Callable)


      symbol_type.instance_scope["=="] = TFunctor.new([
        TNativeDef.new(1) do |this, (arg), _block, _itr|
          this = this.as(TSymbol)
          case arg
          when TSymbol
            TBoolean.new(this.value == arg.value)
          else
            TBoolean.new(false)
          end
        end
      ] of Callable)

      symbol_type.instance_scope["!="] = TFunctor.new([
        TNativeDef.new(1) do |this, (arg), _block, _itr|
          this = this.as(TSymbol)
          case arg
          when TSymbol
            TBoolean.new(this.value != arg.value)
          else
            TBoolean.new(true)
          end
        end
      ] of Callable)

      @kernel.scope["Symbol"] = symbol_type
    end
  end
end
