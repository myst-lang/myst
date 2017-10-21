module Myst
  abstract class Value
    def Value.from_literal(literal : Node)
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

    def type
      raise "Compiler bug: Unknown type for value #{self}"
    end

    def scope
      self.type.instance_scope
    end
  end


  NIL_TYPE          = TType.new("Nil")
  BOOLEAN_TYPE      = TType.new("Boolean")
  INTEGER_TYPE      = TType.new("Integer")
  FLOAT_TYPE        = TType.new("Float")
  STRING_TYPE       = TType.new("String")
  SYMBOL_TYPE       = TType.new("Symbol")
  LIST_TYPE         = TType.new("List")
  MAP_TYPE          = TType.new("Map")
  FUNCTOR_TYPE      = TType.new("Functor")
  FUNCTOR_DEF_TYPE  = TType.new("FunctorDef")
  NATIVE_DEF_TYPE   = TType.new("NativeDef")
  MODULE_TYPE       = TType.new("Module")
  TYPE_TYPE         = TType.new("Type")

  class TType < Value
    property name           : String
    property scope          : Scope
    property instance_scope : Scope

    def initialize(@name : String, parent : Scope?=nil)
      @scope = Scope.new(parent)
      @instance_scope = Scope.new(parent)
    end

    def type
      TYPE_TYPE
    end

    def_equals_and_hash name, scope, instance_scope
  end

  class TInstance < Value
    property type       : TType
    property scope      : Scope

    def initialize(@type : TType)
      @scope = Scope.new(@type.instance_scope)
    end

    def ancestors
      @type.ancestors
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

    def type
      NIL_TYPE
    end

    def_equals_and_hash
  end

  class TBoolean < TPrimitive(Bool)
    def to_s
      @value ? "true" : "false"
    end

    def truthy?
      @value
    end

    def type
      BOOLEAN_TYPE
    end
  end

  class TInteger < TPrimitive(Int64)
    def ==(other : TFloat)
      self.value == other.value
    end

    def type
      INTEGER_TYPE
    end
  end

  class TFloat < TPrimitive(Float64)
    def ==(other : TInteger)
      self.value == other.value
    end

    def type
      FLOAT_TYPE
    end
  end

  class TString < TPrimitive(String)
    def type
      STRING_TYPE
    end
  end

  class TSymbol < TPrimitive(UInt64)
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

    def type
      SYMBOL_TYPE
    end
  end


  class TList < Value
    property elements : Array(Value)

    def initialize(@elements=[] of Value)
    end

    def type
      LIST_TYPE
    end

    def_equals_and_hash elements
  end

  class TMap < Value
    property entries : Hash(Value, Value)

    def initialize(@entries={} of Value => Value)
    end

    def type
      MAP_TYPE
    end

    def_equals_and_hash entries
  end


  abstract class Callable < Value
  end

  # A Functor is a container for multiple functor definitions, which can either
  # be language-level or native.
  class TFunctor < Value
    property  clauses         : Array(Callable)
    property  lexical_scope   : Scope
    property! parent          : TFunctor?

    def initialize(@clauses=[] of Callable, @lexical_scope : Scope=Scope.new)
    end

    def add_clause(definition : Callable)
      clauses.push(definition)
    end

    def type
      FUNCTOR_TYPE
    end

    def_equals_and_hash clauses, lexical_scope, parent?
  end

  class TFunctorDef < Callable
    property  definition : Def

    delegate params, block_param, block_param?, body, splat_index?, splat_index, to: definition

    def initialize(@definition : Def)
    end

    def type
      FUNCTOR_DEF_TYPE
    end

    def_equals_and_hash definition
  end

  class TNativeDef < Callable
    alias FuncT = (Value?, Array(Value), TFunctor?, Interpreter -> Value)
    property arity  : Int32
    property impl   : FuncT

    def initialize(@arity : Int32, &@impl : FuncT)
    end

    def type
      NATIVE_DEF_TYPE
    end

    def_equals_and_hash impl
  end

  class TModule < Value
    property scope   : Scope

    def initialize(parent : Scope? = nil)
      @scope = Scope.new(parent)
    end

    def type
      MODULE_TYPE
    end

    def_equals_and_hash scope
  end
end
