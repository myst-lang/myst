module Myst
  abstract class Value
    # All values except `false` and `nil` are considered truthy. By defining
    # `truthy?` here, only those two cases need to be handled elsewhere.
    def truthy?
      true
    end

    def self.from_literal(literal : AST::Node)
      case literal
      when AST::IntegerLiteral
        TInteger.new(literal.value.to_i64)
      when AST::FloatLiteral
        TFloat.new(literal.value.to_f64)
      when AST::StringLiteral
        TString.new(literal.value)
      when AST::SymbolLiteral
        TSymbol.new(literal.value)
      when AST::BooleanLiteral
        TBoolean.new(literal.value)
      else
        raise "#{literal.class} cannot be converted to a Value."
      end
    end
  end


  class Primitive(T) < Value
    property value : T

    METHODS = Scope.new

    def native_methods
      METHODS
    end

    def initialize(@value : T)
    end

    def initialize(other : self)
      @value = other.value
    end

    macro make_public_op(name, arity)
      METHODS["{{name.id}}"] = TNativeFunctor.new("{{name.id}}", {{arity+1}}) do |args|
        this = args.shift
        next TNil.new unless this.is_a?({{@type}})
        {{ yield }}
      end
    end

    macro simple_op(operator, type, returns)
      def {{operator.id}}(other : {{type.id}}) : {{returns.id}}
        {{returns.id}}.new(self.value {{operator.id}} other.value)
      end
    end

    macro simple_op(operator, type)
      simple_op({{operator}}, {{type}}, returns: {{type}})
    end


    def inspect
      "<#{self.class.name}: #{@value}>"
    end

    def inspect(io : IO)
      io << inspect
    end
  end
end


require "./values/*"
