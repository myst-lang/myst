module Myst
  class TNativeFunctor < Value
    alias FuncT = (Array(Value), TFunctor?, Interpreter -> Value)
    property name           : String
    property arity          : Int32
    property impl           : FuncT
    property parent         : Scope?

    def self.type_name; "NativeFunctor"; end
    def type_name; self.class.type_name; end

    def initialize(@name : String, @arity : Int32, &@impl : FuncT)
    end

    def call(args : Array(Value), block_argument : TFunctor?, interpreter : Interpreter) : Value
      impl.call(args, block_argument, interpreter)
    end

    def ==(other : TNativeFunctor)
      impl == other.impl
    end

    def !=(other : TNativeFunctor)
      impl != other.impl
    end

    def hash
      name.hash + arity
    end
  end
end
