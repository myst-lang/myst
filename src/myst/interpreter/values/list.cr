module Myst
  class TList < Primitive(Array(Value))
    def self.type_name; "List"; end
    def type_name; self.class.type_name; end

    def initialize(@value : Array(Value)); end

    def initialize(other_list : TList)
      @value = other_list.value
    end

    def initialize
      @value = [] of Value
    end

    def ==(other : TList)
      @value.each_with_index do |el, idx|
        return false unless el == other.value[idx]
      end

      true
    end

    def !=(other : TList)
      @value.each_with_index do |el, idx|
        return true unless el == other.value[idx]
      end

      false
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

    def hash
      @value.sum(&.hash)
    end
  end
end
