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

    def self.type_name; "Symbol"; end
    def type_name; self.class.type_name; end


    property name : String

    def initialize(@value : UInt64, @name : String); end


    simple_op :==, TSymbol, returns: TBoolean
    simple_op :!=, TSymbol, returns: TBoolean
  end
end
