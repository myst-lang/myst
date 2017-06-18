module Myst
  class TList < Primitive(Array(Value))
    def initialize(@value : Array(Value)); end

    def initialize(other_list : TList)
      @value = other_list.value
    end

    def initialize
      @value = [] of Value
    end

    def ==(other : TList) : TBoolean
      TBoolean.new(false)
    end

    def !=(other : TList) : TBoolean
      TBoolean.new(true)
    end

    simple_op :+, TList
    simple_op :-, TList


    def push(element : Value)
      @value << element
    end

    def reference(index : TInteger)
      @value[index.value]? || TNil.new
    end

    def set(index : TInteger, new_value : Value)
      if index.value >= @value.size
        (index.value - @value.size + 1).times{ @value << TNil.new }
      end

      @value[index.value] = new_value
    end
  end
end
