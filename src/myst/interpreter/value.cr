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


    macro inherited
      # When a new Value type is created, add a SCOPE constant to it to hold
      # methods and attributes for the Value.
      SCOPE = Scope.new

      def scope; SCOPE; end
    end

    # Instance variables are properties tied to the instance of an object.
    # For consistency between native (Integer, String, etc.) and language-
    # level types (IO, File, etc.), all values have an `ivars` property.
    property ivars : Scope = Scope.new

    # Ancestors are the modules that have been included inside of a Type. For
    # example, if a module includes Enumerable, then the ancestors for that
    # module will contain Enumerable. The order of ancestors is from most to
    # least recent (the last `include` will be first in this list).
    property included_modules = [] of TModule

    def ancestors : Array(TModule)
      @included_modules.reduce(Set(TModule).new) do |acc, mod|
        acc.add(mod)
        acc.concat(mod.ancestors)
      end.to_a
    end

    def insert_ancestor(anc : TModule)
      @included_modules.unshift(anc)
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

    def ==(other : TFloat)
      self.value == other.value
    end
  end

  class TFloat < TPrimitive(Float64)
    def self.type_name; "Float"; end

    def ==(other : TInteger)
      self.value == other.value
    end
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


  class Callable < Value
    def self.type_name; type_name; end
  end

  # A Functor is a container for multiple functor definitions, which can either
  # be language-level or native.
  class TFunctor < Value
    def self.type_name; "Functor"; end
    property  clauses         : Array(Callable)
    property  lexical_scope   : Scope
    property! parent          : TFunctor?

    def initialize(@clauses=[] of Callable, @lexical_scope : Scope=Scope.new)
    end

    def add_clause(definition : Callable)
      clauses.push(definition)
    end

    def_equals_and_hash clauses, lexical_scope, parent?
  end

  class TFunctorDef < Callable
    def self.type_name; "Functor"; end
    property  definition : Def

    delegate params, block_param, block_param?, body, splat_index?, splat_index, to: definition

    def initialize(@definition : Def)
    end

    def_equals_and_hash definition
  end

  class TNativeDef < Callable
    def self.type_name; "NativeFunctor"; end
    alias FuncT = (Value?, Array(Value), TFunctor?, Interpreter -> Value)
    property arity  : Int32
    property impl   : FuncT

    def initialize(@arity : Int32, &@impl : FuncT)
    end

    def_equals_and_hash impl
  end

  class TModule < Value
    def self.type_name; "Module"; end
    property scope   : Scope

    def initialize(parent : Scope? = nil)
      @scope = Scope.new(parent)
    end

    def_equals_and_hash scope
  end


  class TType < Value
    def self.type_name; "Type"; end
    property name           : String
    property scope          : Scope
    property instance_scope : Scope

    def initialize(@name : String, parent : Scope)
      @scope = Scope.new(parent)
      @instance_scope = Scope.new(parent)
    end

    def type_name
      @name
    end

    def_equals_and_hash name, scope, instance_scope
  end

  class TInstance < Value
    def self.type_name; "Instance"; end
    property type       : TType
    property scope      : Scope

    def initialize(@type : TType)
      @scope = Scope.new(@type.instance_scope)
    end

    def ancestors
      @type.ancestors
    end

    def type_name
      @type.type_name
    end
  end
end
