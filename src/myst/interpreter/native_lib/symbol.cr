module Myst
  class Interpreter
    NativeLib.method :symbol_to_s, TSymbol do
      TString.new(this.name)
    end

    NativeLib.method :symbol_eq, TSymbol, other : Value do
      case other
      when TSymbol
        TBoolean.new(this.value == other.value)
      else
        TBoolean.new(false)
      end
    end

    NativeLib.method :symbol_not_eq, TSymbol, other : Value do
      case other
      when TSymbol
        TBoolean.new(this.value != other.value)
      else
        TBoolean.new(true)
      end
    end


    def init_symbol(kernel : TModule)
      symbol_type = TType.new("Symbol", kernel.scope)
      symbol_type.instance_scope["type"] = symbol_type

      NativeLib.def_instance_method(symbol_type, :to_s,  :symbol_to_s)
      NativeLib.def_instance_method(symbol_type, :==,    :symbol_eq)
      NativeLib.def_instance_method(symbol_type, :!=,    :symbol_not_eq)

      symbol_type
    end
  end
end
