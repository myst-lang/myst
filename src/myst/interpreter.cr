require "./visitor"
require "./interpreter/*"

module Myst
  class Interpreter < Visitor
    property stack : StackMachine
    property symbol_table : SymbolTable
    property function_table : FunctionTable

    def initialize
      @stack = StackMachine.new
      @symbol_table = SymbolTable.new
      @function_table = FunctionTable.new
    end

    macro recurse(node)
      {{node}}.accept(self, io)
    end

    visit AST::Node do
      raise "Unsupported node `#{node.class.name}`"
    end



    # Lists

    visit AST::Block, AST::ExpressionList do
      node.children.each{ |child| recurse(child) }
    end



    # Assignments

    visit AST::SimpleAssignment do
      recurse(node.value)
      target = node.target

      # If the target is an identifier, recursing is unnecessary.
      if target.is_a?(AST::VariableReference)
        @symbol_table[target.name] = stack.pop
      end
    end

    visit AST::FunctionDefinition do
      @function_table.define(node.name, Functor.new(node))
    end



    # Binary Expressions

    visit AST::LogicalExpression do
      recurse(node.left)
      recurse(node.right)

      b = stack.pop
      a = stack.pop

      case node.operator.type
      when Token::Type::ANDAND
        stack.push(Value.new(a.raw && b.raw))
      when Token::Type::OROR
        stack.push(Value.new(a.raw || b.raw))
      end
    end

    visit AST::EqualityExpression do
      recurse(node.left)
      recurse(node.right)

      b = stack.pop
      a = stack.pop

      case node.operator.type
      when Token::Type::EQUALEQUAL
        stack.push(Value.new(a.raw == b.raw))
      when Token::Type::NOTEQUAL
        stack.push(Value.new(a.raw != b.raw))
      end
    end

    visit AST::RelationalExpression do
      recurse(node.left)
      recurse(node.right)

      b = stack.pop
      a = stack.pop

      case node.operator.type
      when Token::Type::LESS
        case
        when a.is_numeric? && b.is_numeric?
          stack.push(Value.new(a.as_numeric < b.as_numeric))
        when a.is_string? && b.is_string?
          stack.push(Value.new(a.as_string < b.as_string))
        else
          raise "`<` is not supported for #{a.type} and #{b.type}"
        end
      when Token::Type::LESSEQUAL
        case
        when a.is_numeric? && b.is_numeric?
          stack.push(Value.new(a.as_numeric <= b.as_numeric))
        when a.is_string? && b.is_string?
          stack.push(Value.new(a.as_string <= b.as_string))
        else
          raise "`<=` is not supported for #{a.type} and #{b.type}"
        end
      when Token::Type::GREATEREQUAL
        case
        when a.is_numeric? && b.is_numeric?
          stack.push(Value.new(a.as_numeric >= b.as_numeric))
        when a.is_string? && b.is_string?
          stack.push(Value.new(a.as_string >= b.as_string))
        else
          raise "`>=` is not supported for #{a.type} and #{b.type}"
        end
      when Token::Type::GREATER
        case
        when a.is_numeric? && b.is_numeric?
          stack.push(Value.new(a.as_numeric > b.as_numeric))
        when a.is_string? && b.is_string?
          stack.push(Value.new(a.as_string > b.as_string))
        else
          raise "`>` is not supported for #{a.type} and #{b.type}"
        end
      end
    end

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
          raise "`*` is not supported for #{a.type} and #{b.type}"
        end
      when Token::Type::SLASH
        case
        when a.is_numeric? && b.is_numeric?
          stack.push(Value.new(a.as_numeric + b.as_numeric))
        else
          raise "`/` is not supported for #{a.type} and #{b.type}"
        end
      end
    end



    # Postfix Expressions

    visit AST::FunctionCall do
      functor = case (func = node.function)
      when AST::VariableReference
        @function_table[func.name]
      else
        raise "Function calls must use an identifier as the name."
      end

      recurse(node.arguments)
      # Functions get a new scope. This will need to be rethought when
      # classes/modules are supported, or nesting function calls happens.
      @symbol_table.push_scope()
      functor[0].parameters.children.each do |param|
        # Pop arguments from the stack into the variables named by the
        # parameters for the function.
        @symbol_table.assign(param.name, stack.pop(), recurse: false)
      end
      recurse functor[0].body
      @symbol_table.pop_scope()

      puts stack
    end



    # Literals

    visit AST::VariableReference do
      stack.push(@symbol_table[node.name])
    end

    visit AST::IntegerLiteral do
      stack.push(Value.new(node.value.to_i64))
    end

    visit AST::FloatLiteral do
      stack.push(Value.new(node.value.to_f64))
    end

    visit AST::StringLiteral do
      stack.push(Value.new(node.value))
    end

    visit AST::BooleanLiteral do
      stack.push(Value.new(node.value))
    end
  end
end
