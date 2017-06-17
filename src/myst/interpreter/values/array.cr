module Myst
  class TArray < Primitive(Array(Value))
    def ==(other : TArray) : TBoolean
      TBoolean.new(false)
    end

    def !=(other : TArray) : TBoolean
      TBoolean.new(true)
    end

    simple_op :+, TArray
    simple_op :-, TArray
  end
end
