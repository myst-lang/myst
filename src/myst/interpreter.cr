require "./visitor"
require "./interpreter/*"

module Myst
  class Interpreter < Visitor
    include Matcher

    property stack : StackMachine
    property symbol_table : SymbolTable


    def initialize
      @stack = StackMachine.new
      @symbol_table = SymbolTable.new
      @symbol_table.push_scope(Kernel::SCOPE)
    end

    macro recurse(node, io_override=nil)
      {% if io_override %}
        {{node}}.accept(self, {{io_override}})
      {% else %}
        {{node}}.accept(self, io)
      {% end %}
    end

    visit AST::Node do
      raise "Unsupported node `#{node.class.name}`"
    end



    # Lists

    visit AST::Block do
      # If the block has no statements, push a nil value onto the stack as an
      # implicit return value.
      if node.children.empty?
        stack.push(TNil.new)
      else
        node.children.each_with_index do |child, index|
          recurse(child)
          # All expressions push a value onto the stack. The top-level expression
          # will return an unused value, which should be popped from the stack to
          # avoid leaking memory. However, the last expression in a block is the
          # implicit return value, so it should stay on the stack.
          stack.pop() unless index == node.children.size - 1
        end
      end
    end

    visit AST::ExpressionList do
      node.children.each do |child|
        recurse(child)
      end
    end



    # Statements

    visit AST::ModuleDefinition do
      _module = TObject.new
      @symbol_table[node.name] = _module
      @symbol_table.push_scope(_module)
      recurse(node.body)
      @symbol_table.pop_scope
      stack.push(_module)
    end

    visit AST::FunctionDefinition do
      functor = TFunctor.new(node, @symbol_table.current_scope)
      @symbol_table[node.name] = functor
      stack.push(functor)
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

    visit AST::PatternMatchingAssignment do
      recurse(node.value, io)
      result = match(node.pattern, stack.pop(), io)
      stack.push(result)
    end



    # Conditionals

    visit AST::IfExpression, AST::ElifExpression do
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
    end

    visit AST::UnlessExpression do
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
    end

    visit AST::ElseExpression do
      recurse(node.body)
    end

    visit AST::WhileExpression do
      recurse(node.condition)
      while stack.pop().truthy?
        recurse(node.body)
        recurse(node.condition)
      end
    end

    visit AST::UntilExpression do
      recurse(node.condition)
      until stack.pop().truthy?
        recurse(node.body)
        recurse(node.condition)
      end
    end


    # Binary Expressions

    visit AST::LogicalExpression do
      case node.operator.type
      when Token::Type::ANDAND
        recurse(node.left)
        return unless stack.last.truthy?
        stack.pop
        # Recursing the right node should leave it's result on the stack
        recurse(node.right)
      when Token::Type::OROR
        recurse(node.left)
        return if stack.last.truthy?
        stack.pop
        # Recursing the right node should leave it's result on the stack
        recurse(node.right)
      end
    end

    visit AST::EqualityExpression, AST::RelationalExpression, AST::BinaryExpression do
      recurse(node.left)
      recurse(node.right)

      b = stack.pop
      a = stack.pop

      stack.push(Calculator.do(node.operator.type, a, b))
    end



    # Postfix Expressions

    visit AST::FunctionCall do
      recurse(node.receiver)
      func = stack.pop

      case func
      when TFunctor
        recurse(node.arguments)
        @symbol_table.push_scope(func.scope.full_clone)
        func.parameters.children.reverse_each do |param|
          @symbol_table.assign(param.name, stack.pop(), make_new: true)
        end
        recurse(func.body)
        @symbol_table.pop_scope()
      when TNativeFunctor
        recurse(node.arguments)
        args = node.arguments.children.map{ |arg| stack.pop() }.reverse
        stack.push(func.call(args))
      else
        raise "#{func} is not a functor value."
      end
    end

    visit AST::AccessExpression do
      recurse(node.target)
      recurse(node.key)
      key     = stack.pop
      target  = stack.pop

      case target
      when TList
        if key.is_a?(TInteger)
          stack.push(target.reference(key))
        else
          raise "Access for lists only supports integer keys. Got #{key.class}"
        end
      when TMap
        stack.push(target.reference(key))
      else
        raise "Access is not supported for #{target.class}."
      end
    end

    visit AST::AccessSetExpression do
      recurse(node.target)
      recurse(node.key)
      recurse(node.value)
      value   = stack.pop
      key     = stack.pop
      target  = stack.pop

      case target
      when TList
        if key.is_a?(TInteger)
          target.set(key, value)
          stack.push(target.reference(key))
        else
          raise "Access for lists only supports integer keys. Got #{key.class}"
        end
      when TMap
        target.set(key, value)
        stack.push(target.reference(key))
      else
        raise "Access is not supported for #{target.class}."
      end
    end

    visit AST::MemberAccessExpression do
      recurse(node.receiver)
      receiver = stack.pop

      case receiver
      when TObject
        member_name = node.member
        stack.push(receiver[member_name])
      else
        raise "#{receiver} does not allow member access."
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

    visit AST::IntegerLiteral, AST::FloatLiteral, AST::StringLiteral, AST::SymbolLiteral, AST::BooleanLiteral do
      stack.push(Value.from_literal(node))
    end


    visit AST::ListLiteral do
      recurse(node.elements)
      elements = node.elements.children.map{ |el| stack.pop }
      stack.push(TList.new(elements.reverse))
    end

    visit AST::MapLiteral do
      # The elements should push value pairs onto the stack:
      # STACK
      # | value2
      # | key2
      # | value1
      # V key1
      recurse(node.elements)
      map_entries = node.elements.children.map do |el|
        value, key = stack.pop, stack.pop
        {key, value}
      end

      map = TMap.new
      map_entries.reverse_each do |key, value|
        map.assign(key, value)
      end
      stack.push(map)
    end

    visit AST::MapEntryDefinition do
      recurse(node.key)
      recurse(node.value)
    end

    visit AST::ValueInterpolation do
      recurse(node.value)
    end
  end
end
