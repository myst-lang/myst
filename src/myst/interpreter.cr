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

    visit AST::Block do
      node.children.each_with_index do |child, index|
        recurse(child)
        # The last expression in a block is the implicit return value, so
        # it should stay on the stack.
        stack.pop() unless index == node.children.size - 1
      end
    end

    visit AST::ExpressionList do
      node.children.each do |child|
        recurse(child)
      end
    end



    # Statements

    visit AST::FunctionDefinition do
      functor = Functor.new(node)
      @function_table.define(node.name, functor)
      stack.push(TFunctor.new)
    end



    # Assignments

    visit AST::SimpleAssignment do
      recurse(node.value)
      target = node.target

      # If the target is an identifier, recursing is unnecessary.
      if target.is_a?(AST::VariableReference)
        # The return value of an assignment is the value being assigned,
        # so there is no need to pop it from the stack. This also ensures
        # that the value is treated as a reference, rather than a copy.
        @symbol_table[target.name] = stack.last
      end
    end



    # Conditionals

    visit AST::ConditionalExpression do
      case node.inversion.type
      when Token::Type::IF, Token::Type::ELIF
        recurse(node.condition.not_nil!)
        if stack.pop().truthy?
          recurse(node.body)
        else
          if node.alternative
            recurse(node.alternative.not_nil!)
          else
            stack.push(TNil.new)
          end
        end
      when Token::Type::UNLESS
        recurse(node.condition.not_nil!)
        unless stack.pop().truthy?
          recurse(node.body)
        else
          if node.alternative
            recurse(node.alternative.not_nil!)
          else
            stack.push(TNil.new)
          end
        end
      when Token::Type::ELSE
        recurse(node.body)
      end
    end


    # Binary Expressions

    visit AST::LogicalExpression do
      case node.operator.type
      when Token::Type::ANDAND
        recurse(node.left)
        a = stack.pop()

        unless a.truthy?
          stack.push(a)
          return
        end

        recurse(node.right)
        b = stack.pop()
        stack.push(b)
      when Token::Type::OROR
        recurse(node.left)
        a = stack.pop()

        if a.truthy?
          stack.push(a)
          return
        end

        recurse(node.right)
        b = stack.pop()
        stack.push(b)
      end
    end

    visit AST::EqualityExpression, AST::RelationalExpression, AST::BinaryExpression do
      recurse(node.left)
      recurse(node.right)

      b = stack.pop
      a = stack.pop

      stack.push(Calculator.do(node.operator, a, b))
    end



    # Postfix Expressions

    visit AST::FunctionCall do
      case (func = node.function)
      when AST::VariableReference
        if functors = @function_table[func.name]?
          matched_functor = functors[0]
          recurse(node.arguments)
          # Functions get a new scope. This will need to be rethought when
          # classes/modules are supported, or nesting function calls happens.
          @symbol_table.push_scope(Scope.new(restrictive: true))
          matched_functor.parameters.children.reverse_each do |param|
            # Pop arguments from the stack into the variables named by the
            # parameters for the function.
            @symbol_table.assign(param.name, stack.pop(), make_new: true)
          end
          recurse(matched_functor.body)
          @symbol_table.pop_scope()
        # If a function to call wasn't found, try to lookup a Kernel method.
        else
          recurse(node.arguments)
          {% for method in Kernel.methods %}
            if func.name == {{method.name.stringify}}
              args = [] of Value
              node.arguments.children.each do |arg|
                args << stack.pop
              end

              return Kernel.{{method.name}}(args)
            end
          {% end %}
        end
      else
        raise "Function names must be identifiers."
      end
    end



    # Literals

    visit AST::VariableReference do
      if value = @symbol_table[node.name]?
        stack.push(value)
      else
        raise "Undefined variable `#{node.name}` in current scope."
      end
    end

    visit AST::IntegerLiteral do
      stack.push(TInteger.new(node.value.to_i64))
    end

    visit AST::FloatLiteral do
      stack.push(TFloat.new(node.value.to_f64))
    end

    visit AST::StringLiteral do
      stack.push(TString.new(node.value))
    end

    visit AST::BooleanLiteral do
      stack.push(TBoolean.new(node.value))
    end
  end
end
