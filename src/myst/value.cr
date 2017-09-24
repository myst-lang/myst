module Myst
  abstract class Value
    def type_name; self.class.type_name; end

    def self.from_literal(literal : Node)
      case literal
      when IntegerLiteral
        TInteger.new(literal.value.to_i64)
      when FloatLiteral
        TFloat.new(literal.value.to_f64)
      when StringLiteral
        TString.new(literal.value)
      when SymbolLiteral
        TSymbol.new(literal.value)
      when BooleanLiteral
        TBoolean.new(literal.value)
      when NilLiteral
        TNil.new
      else
        raise "#{literal.class} cannot be converted to a Value."
      end
    end


    def truthy?
      true
    end
  end

  # Primitives are immutable objects
  abstract class TPrimitive(T) < Value
    property value : T

    def initialize(@value : T); end

    def to_s
      value.to_s
    end

    def_equals_and_hash value
  end

  class TNil < Value
    def self.type_name; "Nil"; end
    # All instances of Nil in a program refer to the same object.
    NIL_OBJECT = TNil.allocate

    def self.new
      return NIL_OBJECT
    end

    def to_s
      "nil"
    end

    def truthy?
      false
    end

    def_equals_and_hash
  end

  class TBoolean < TPrimitive(Bool)
    def self.type_name; "Boolean"; end

    def to_s
      @value ? "true" : "false"
    end

    def truthy?
      @value
    end
  end

  class TInteger < TPrimitive(Int64)
    def self.type_name; "Integer"; end
  end

  class TFloat < TPrimitive(Float64)
    def self.type_name; "Float"; end
  end

  class TString < TPrimitive(String)
    def self.type_name; "String"; end
  end

  class TSymbol < TPrimitive(UInt64)
    def self.type_name; "Symbol"; end
    SYMBOLS = {} of String => TSymbol
    @@next_id = 0_u64

    property name : String

    def initialize(@value : UInt64, @name : String)
    end

    def self.new(name)
      SYMBOLS[name] ||= begin
        instance = TSymbol.allocate
        instance.initialize(@@next_id += 1, name)
        instance
      end
    end
  end


  class TList < Value
    def self.type_name; "List"; end
    property elements : Array(Value)

    def initialize(@elements=[] of Value)
    end

    def_equals_and_hash elements
  end

  class TMap < Value
    def self.type_name; "Map"; end
    property entries : Hash(Value, Value)

    def initialize(@entries={} of Value => Value)
    end

    def_equals_and_hash entries
  end
end
