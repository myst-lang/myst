require "./visitor"
require "./interpreter/*"

module Myst
  class Interpreter < Visitor
    property stack : StackMachine

    def initialize
      @stack = StackMachine.new
    end

    macro recurse(node)
      {{node}}.accept(self, io)
    end

    visit AST::Node do
      raise "Unsupported node `#{node.class.name}`"
    end

    visit AST::Block do
      node.children.each{ |child| recurse(child) }
    end



    # Arithmetic operations

    visit AST::BinaryExpression do
      recurse(node.left)
      recurse(node.right)

      b = stack.pop
      a = stack.pop

      case node.operator.type
      when Token::Type::PLUS
        case
        when a.is_numeric? && b.is_numeric?
          stack.push(Value.new(a.as_numeric + b.as_numeric))
        when a.is_numeric? && !b.is_numeric?
          raise "`+` is not supported for Numeric + Non-Numeric"
        when a.is_string? && !b.is_nil?
          stack.push(Value.new(a.as_string + b.to_s))
        else
          raise "`+` is not supported for #{a.type} and #{b.type}"
        end
      when Token::Type::MINUS
        case
        when a.is_numeric? && b.is_numeric?
          stack.push(Value.new(a.as_numeric + b.as_numeric))
        else
          raise "`-` is not supported for #{a.type} and #{b.type}"
        end
      when Token::Type::STAR
        case
        when a.is_numeric? && b.is_numeric?
          stack.push(Value.new(a.as_numeric + b.as_numeric))
        when a.is_string? && b.is_int?
          stack.push(Value.new(a.as_string * b.as_int))
        else
          raise "`-` is not supported for #{a.type} and #{b.type}"
        end
      when Token::Type::SLASH
        case
        when a.is_numeric? && b.is_numeric?
          stack.push(Value.new(a.as_numeric + b.as_numeric))
        else
          raise "`-` is not supported for #{a.type} and #{b.type}"
        end
      end
    end



    # Literals

    visit AST::IntegerLiteral do
      stack.push(Value.new(node.value.to_i64))
    end

    visit AST::FloatLiteral do
      stack.push(Value.new(node.value.to_f64))
    end

    visit AST::StringLiteral do
      stack.push(Value.new(node.value))
    end
  end
end
