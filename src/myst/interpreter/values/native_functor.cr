module Myst
  class TNativeFunctor < Value
    alias FuncT = (Array(Value) -> Value)
    property name   : String
    property arity  : Int32
    property impl   : FuncT

    def initialize(@name : String, @arity : Int32, &@impl : FuncT)
    end

    def call(params : Array(Value)) : Value
      impl.call(params)
    end

    def ==(other : TNativeFunctor) : TBoolean
      TBoolean.new(impl == other.impl)
    end

    def !=(other : TNativeFunctor) : TBoolean
      TBoolean.new(impl != other.impl)
    end
  end
end
