module Myst
  class TSymbol < Primitive(UInt64)
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


    simple_op :==, TSymbol, returns: TBoolean
    simple_op :!=, TSymbol, returns: TBoolean


    def to_s
      if @name.includes?(' ')
        "\"#{@name}\""
      else
        @name
      end
    end
  end
end
