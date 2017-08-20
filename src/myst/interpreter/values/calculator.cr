require "./*"
require "../../parser/token.cr"


module Myst
  # This module is responsible for enforcing type rules on binary operations
  # (except for logicals). Each value type is responsible for defining the
  # implementation of all valid operations. This module simply ensures that
  # no invalid operations are attempted.
  module Calculator
    extend self

    # Perform a calculating operation. That is, any operation applied to two
    # operands to generate a new result value. Logical operations are not
    # included, as they short-circuit and thus may not evaluate both operands.
    def do(operator : Token::Type, left : Value, right : Value) : Value
      case operator
      when Token::Type::EQUALEQUAL
        return equal(left, right)
      when Token::Type::NOTEQUAL
        return not_equal(left, right)
      when Token::Type::LESS
        return less(left, right)
      when Token::Type::LESSEQUAL
        return less_equal(left, right)
      when Token::Type::GREATEREQUAL
        return greater_equal(left, right)
      when Token::Type::GREATER
        return greater(left, right)
      when Token::Type::PLUS
        return add(left, right)
      when Token::Type::MINUS
        return subtract(left, right)
      when Token::Type::STAR
        return multiply(left, right)
      when Token::Type::SLASH
        return divide(left, right)
      else
        raise "Unknown calculation operator #{operator}"
      end
    end

    macro simple_op_for(op, *types, returns=nil)
      {% for type in types %}
        if left.is_a?({{type.id}}) && right.is_a?({{type.id}})
          return {{(returns || type).id}}.new(left {{op.id}} right)
        end
      {% end %}
    end

    macro simple_mixed_type_op(left_type, op, right_type, returns)
      if left.is_a?({{left_type.id}}) && right.is_a?({{right_type.id}})
        return {{returns.id}}.new(left {{op.id}} right)
      end
    end


    # Equality

    def equal(left, right) : TBoolean
      # Left and right cannot be equal if their are different types
      return TBoolean.new(false) unless typeof(left) == typeof(right)
      simple_op_for :==, TInteger, TFloat, TBoolean, TString, TSymbol, TNil, TList, TObject, TFunctor, returns: TBoolean
      return TBoolean.new(false)
    end

    def not_equal(left, right) : TBoolean
      simple_op_for :!=, TInteger, TFloat, TBoolean, TString, TSymbol, TNil, TList, TObject, TFunctor, returns: TBoolean
      return TBoolean.new(true)
    end


    # Comparison

    def less(left, right)
      simple_op_for :<, TInteger, TFloat, TString, returns: TBoolean
      # Any kind of numeric type can be compared.
      simple_mixed_type_op TInteger, :<, TFloat, returns: TBoolean
      simple_mixed_type_op TFloat, :<, TInteger, returns: TBoolean
      return TBoolean.new(false)
    end

    def less_equal(left, right)
      simple_op_for :<=, TInteger, TFloat, TString, returns: TBoolean
      # Any kind of numeric type can be compared.
      simple_mixed_type_op TInteger, :<=, TFloat, returns: TBoolean
      simple_mixed_type_op TFloat, :<=, TInteger, returns: TBoolean
      return TBoolean.new(false)
    end

    def greater_equal(left, right)
      simple_op_for :>=, TInteger, TFloat, TString, returns: TBoolean
      # Any kind of numeric type can be compared.
      simple_mixed_type_op TInteger, :>=, TFloat, returns: TBoolean
      simple_mixed_type_op TFloat, :>=, TInteger, returns: TBoolean
      return TBoolean.new(false)
    end

    def greater(left, right)
      simple_op_for :>, TInteger, TFloat, TString, returns: TBoolean
      # Any kind of numeric type can be compared.
      simple_mixed_type_op TInteger, :>, TFloat, returns: TBoolean
      simple_mixed_type_op TFloat, :>, TInteger, returns: TBoolean
      return TBoolean.new(false)
    end


    # Arithmetic

    def add(left, right)
      simple_op_for :+, TInteger, TFloat, TString, TList
      simple_mixed_type_op TInteger, :+, TFloat, returns: TFloat
      simple_mixed_type_op TFloat, :+, TInteger, returns: TFloat
      raise "Addition is not supported for #{left.class} and #{right.class}"
    end

    def subtract(left, right)
      simple_op_for :-, TInteger, TFloat, TList
      simple_mixed_type_op TInteger, :-, TFloat, returns: TFloat
      simple_mixed_type_op TFloat, :-, TInteger, returns: TFloat
      raise "Subtraction not supported for #{left.class} and #{right.class}"
    end

    def multiply(left, right)
      simple_op_for :*, TInteger, TFloat
      simple_mixed_type_op TInteger, :*, TFloat, returns: TFloat
      simple_mixed_type_op TFloat, :*, TInteger, returns: TFloat

      simple_mixed_type_op TString, :*, TInteger, returns: TString

      raise "Multiplication is not supported for #{left.class} and #{right.class}"
    end

    def divide(left, right)
      simple_op_for :/, TInteger, TFloat
      # Only numeric types can be divided
      simple_mixed_type_op TInteger, :/, TFloat, returns: TFloat
      simple_mixed_type_op TFloat, :/, TInteger, returns: TFloat
      raise "Division is not supported for #{left.class} and #{right.class}"
    end
  end
end
