module Myst
  class Interpreter
    NativeLib.method :symbol_to_s, TSymbol do
      this.name
    end

    NativeLib.method :symbol_eq, TSymbol, other : MTValue do
      case other
      when TSymbol
        this == other
      else
        false
      end
    end

    NativeLib.method :symbol_not_eq, TSymbol, other : MTValue do
      case other
      when TSymbol
        this != other
      else
        true
      end
    end


    def init_symbol
      symbol_type = __make_type("Symbol", @kernel.scope)

      NativeLib.def_instance_method(symbol_type, :to_s,  :symbol_to_s)
      NativeLib.def_instance_method(symbol_type, :==,    :symbol_eq)
      NativeLib.def_instance_method(symbol_type, :!=,    :symbol_not_eq)

      symbol_type
    end
  end
end
