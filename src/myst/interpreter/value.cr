module Myst
  abstract class Value
    # All values except `false` and `nil` are considered truthy. By defining
    # `truthy?` here, only those two cases need to be handled elsewhere.
    def truthy?
      true
    end

    # Same as above for `same?`, primarily used for specs.
    def same?
      false
    end

    abstract def type_name

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
      when AST::NilLiteral
        TNil.new
      else
        raise "#{literal.class} cannot be converted to a Value."
      end
    end
  end


  class Primitive(T) < Value
    property value : T

    def self.type_name; T.name; end
    def type_name; self.class.type_name; end

    def initialize(@value : T)
    end

    def initialize(other : self)
      @value = other.value
    end

    def same?(other : self)
      @value == other.value
    end


    macro simple_op(operator, type, returns)
      def {{operator.id}}(other : {{type.id}}) : {{returns.id}}
        {{returns.id}}.new(self.value {{operator.id}} other.value)
      end
    end

    macro simple_op(operator, type)
      def {{operator.id}}(other : {{type.id}})
        self.value {{operator.id}} other.value
      end
    end


    def inspect
      "<#{self.type_name}: #{@value}>"
    end

    def inspect(io : IO)
      io << inspect
    end
  end
end
