module Myst
  class TSymbol < Primitive(UInt64)
    def self.type_name; "Symbol"; end
    def type_name; self.class.type_name; end

    SYMBOLS = {} of String => TSymbol
    @@next_id = 0_u64

    def self.new(name : String)
      SYMBOLS[name] ||= begin
        instance = TSymbol.allocate
        instance.initialize(@@next_id += 1, name)
        instance
      end
    end


    property name : String

    def initialize(@value : UInt64, @name : String); end


    def ==(other : TSymbol)
      self.value == other.value
    end

    def ==(other : Value)
      false
    end

    def !=(other : Value)
      !(self == other)
    end

    def hash
      @value.hash
    end


    def inspect
      "<#{self.type_name}: #{@name}>"
    end
  end
end
