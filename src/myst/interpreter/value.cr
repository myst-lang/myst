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

    def initialize(@value : T)
    end

    def initialize(other : self)
      @value = other.value
    end

    macro simple_op(operator, type, returns)
      def {{operator.id}}(other : {{type.id}}) : {{returns.id}}
        {{returns.id}}.new(self.value {{operator.id}} other.value)
      end
    end

    macro simple_op(operator, type)
      simple_op({{operator}}, {{type}}, returns: {{type}})
    end

    def hash
      @value.hash
    end

    def to_s
      @value.to_s
    end

    def to_s(io : IO)
      io << to_s
    end

    def inspect
      "<#{self.class.name}: #{to_s}>"
    end

    def inspect(io : IO)
      io << inspect
    end
  end


  class TObject < Value
    property data : Scope

    def initialize
      @data = Scope.new
    end
  end
end


require "./values/*"
