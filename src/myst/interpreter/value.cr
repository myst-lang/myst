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


    def truthy?
      true
    end

    def type_name
      raise "Compiler bug: unknown type name for value #{self}"
    end
  end

  abstract class ContainerType < Value
    property name           : String = ""
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
  end

  class TModule < ContainerType
    property scope   : Scope

    def initialize(name : String? = nil, parent : Scope? = nil)
      @name = name if name
      @scope = Scope.new(parent)
    end

    def type_name
      "Module"
    end

    def_equals_and_hash scope
  end

  class TType < ContainerType
    property scope          : Scope
    property instance_scope : Scope

    def initialize(@name : String, parent : Scope?=nil)
      @scope = Scope.new(parent)
      @instance_scope = Scope.new(parent)
    end

    def type_name
      "Type"
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

    def type_name
      @type.name
    end

    def_equals_and_hash type, scope
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

    def type_name
      "Nil"
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

    def type_name
      "Boolean"
    end
  end

  class TInteger < TPrimitive(Int64)
    def ==(other : TFloat)
      self.value == other.value
    end

    def type_name
      "Integer"
    end
  end

  class TFloat < TPrimitive(Float64)
    def ==(other : TInteger)
      self.value == other.value
    end

    def type_name
      "Float"
    end
  end

  class TString < TPrimitive(String)
    def type_name
      "String"
    end
  end

  class TSymbol < TPrimitive(UInt64)
    SYMBOLS = {} of String => TSymbol
    @@next_id = 0_u64

    property name : String

    def initialize(@value : UInt64, @name : String)
    end

    def type_name
      "Symbol"
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
    property elements : Array(Value)

    def initialize(@elements=[] of Value)
    end

    def type_name
      "List"
    end

    def_equals_and_hash elements
  end

  class TMap < Value
    property entries : Hash(Value, Value)

    def initialize(@entries={} of Value => Value)
    end

    def type_name
      "Map"
    end

    def_equals_and_hash entries
  end


  class TFunctorDef < Value
    property  definition : Def

    delegate params, block_param, block_param?, body, splat_index?, splat_index, to: definition

    def initialize(@definition : Def)
    end

    def_equals_and_hash definition
  end

  alias TNativeDef = Value, Array(Value), TFunctor? -> Value
  alias Callable = TFunctorDef | TNativeDef


  # A Functor is a container for multiple functor definitions, which can either
  # be language-level or native.
  class TFunctor < Value
    property  clauses         : Array(Callable)
    property  lexical_scope   : Scope
    property? closure         : Bool

    def initialize(@clauses=[] of Callable, @lexical_scope : Scope=Scope.new, @closure : Bool=false)
    end

    def add_clause(definition : Callable)
      clauses.push(definition)
    end

    def type_name
      "Functor"
    end

    def new_scope
      closure? ? ClosureScope.new(@lexical_scope) : Scope.new(@lexical_scope)
    end

    def_equals_and_hash clauses, lexical_scope
  end
end
