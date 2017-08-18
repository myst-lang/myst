module Myst
  class TNativeFunctor < Value
    alias FuncT = (Array(Value), TFunctor?, Interpreter -> Value)
    property name           : String
    property arity          : Int32
    property impl           : FuncT

    def self.type_name; "NativeFunctor"; end
    def type_name; self.class.type_name; end

    def initialize(@name : String, @arity : Int32, &@impl : FuncT)
    end

    def call(params : Array(Value), block_argument : TFunctor?, interpreter : Interpreter) : Value
      impl.call(params, block_argument, interpreter)
    end

    def ==(other : TNativeFunctor) : TBoolean
      TBoolean.new(impl == other.impl)
    end

    def !=(other : TNativeFunctor) : TBoolean
      TBoolean.new(impl != other.impl)
    end
  end
end
