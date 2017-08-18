require "./interpreter/*"

module Myst
  class Interpreter
    include Matcher

    property stack : StackMachine
    property symbol_table : SymbolTable

    def initialize
      @stack = StackMachine.new
      @symbol_table = SymbolTable.new
      @symbol_table.push_scope(Kernel::SCOPE)
    end


    macro recurse(node)
      {{node}}.accept(self)
    end


    def visit(node : AST::Node)
      raise "Unsupported node `#{node.class.name}`"
    end



    # Lists

    def visit(node : AST::Block)
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

    def visit(node : AST::ExpressionList)
      node.children.each do |child|
        recurse(child)
      end
    end



    # Statements

    def visit(node : AST::RequireStatement)
      recurse(node.path)
      result = DependencyLoader.require(stack.pop, node.working_dir)

      # If the code was loaded into a node, visit it to evalute it's contents.
      if result.is_a?(AST::Node)
        recurse(result)
      else
        # If the code was _not_ loaded, return a false value.
        stack.push(TBoolean.new(false))
      end
    end

    def visit(node : AST::ModuleDefinition)
      _module = begin
        if @symbol_table[node.name]?
          @symbol_table[node.name]
        else
          @symbol_table[node.name] = TObject.new
        end
      end
      @symbol_table.push_scope(_module.as(Scope))
      recurse(node.body)
      @symbol_table.pop_scope
      stack.push(_module)
    end

    def visit(node : AST::FunctionDefinition)
      functor = TFunctor.new(node, @symbol_table.current_scope)
      @symbol_table[node.name] = functor
      stack.push(functor)
    end



    # Assignments

    def visit(node : AST::SimpleAssignment)
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

    def visit(node : AST::PatternMatchingAssignment)
      recurse(node.value)
      result = match(node.pattern, stack.pop())
      stack.push(result)
    end



    # Conditionals

    def visit(node : AST::IfExpression | AST::ElifExpression)
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

    def visit(node : AST::UnlessExpression)
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

    def visit(node : AST::ElseExpression)
      recurse(node.body)
    end

    def visit(node : AST::WhileExpression)
      recurse(node.condition)
      while stack.pop().truthy?
        recurse(node.body)
        recurse(node.condition)
      end
    end

    def visit(node : AST::UntilExpression)
      recurse(node.condition)
      until stack.pop().truthy?
        recurse(node.body)
        recurse(node.condition)
      end
    end


    # Binary Expressions

    def visit(node : AST::LogicalExpression)
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

    def visit(node : AST::EqualityExpression | AST::RelationalExpression | AST::BinaryExpression)
      recurse(node.left)
      recurse(node.right)

      b = stack.pop
      a = stack.pop

      stack.push(Calculator.do(node.operator.type, a, b))
    end



    # Postfix Expressions

    def visit(node : AST::FunctionCall)
      recurse(node.receiver)
      func = stack.pop

      case func
      when TFunctor
        recurse(node.arguments)
        @symbol_table.push_scope(func.scope.full_clone)
        func.parameters.children.reverse_each do |param|
          @symbol_table.assign(param.name, stack.pop(), make_new: true)
        end
        if block_def = node.block
          recurse(block_def)
          @symbol_table.assign("$block_argument", stack.pop(), make_new: true)
        end
        recurse(func.body)
        @symbol_table.pop_scope()
      when TNativeFunctor
        recurse(node.arguments)
        args = [] of Value
        func.arity.times{ args << stack.pop() }
        if block_def = node.block
          recurse(block_def)
          stack.push(func.call(args.reverse, stack.pop().as(TFunctor), self))
        else
          stack.push(func.call(args.reverse, nil, self))
        end
      else
        raise "#{func} is not a functor value."
      end
    end

    def visit(node : AST::AccessExpression)
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

    def visit(node : AST::AccessSetExpression)
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

    def visit(node : AST::MemberAccessExpression)
      recurse(node.receiver)
      receiver = stack.pop
      member_name = node.member

      case receiver
      when TObject, Scope
        stack.push(receiver[member_name])
      when Primitive
        if native_method = Kernel::PRIMITIVE_APIS[receiver.type_name][member_name]?
          stack.push(receiver)
          stack.push(native_method)
        else
          stack.push(TNil.new)
        end
      else
        raise "#{receiver} does not allow member access."
      end
    end


    # Keyword Expressions
    def visit(node : AST::YieldExpression)
      # Block accessibility is limited to the current scope. If a function
      # given a block in turn calls another function that `yield`s but does not
      # provide a block, the inner function should not be able to `yield` to
      # the outer function's block. Instead, an error should be raised that the
      # inner function expected a block argument.
      if block = @symbol_table.current_scope["$block_argument"]?.as(TFunctor)
        recurse(node.arguments)
        @symbol_table.push_scope(block.scope.full_clone)
        block.parameters.children.reverse_each do |param|
          @symbol_table.assign(param.name, stack.pop(), make_new: true)
        end
        recurse(block.body)
        @symbol_table.pop_scope()
      else
        raise "Attempted to yield when no block was given."
      end
    end


    # Literals

    def visit(node : AST::VariableReference)
      if value = @symbol_table[node.name]?
        stack.push(value)
      else
        raise "Undefined variable `#{node.name}` in current scope."
      end
    end

    def visit(node : AST::IntegerLiteral | AST::FloatLiteral | AST::StringLiteral | AST::SymbolLiteral | AST::BooleanLiteral)
      stack.push(Value.from_literal(node))
    end


    def visit(node : AST::ListLiteral)
      recurse(node.elements)
      elements = node.elements.children.map{ |el| stack.pop }
      stack.push(TList.new(elements.reverse))
    end

    def visit(node : AST::MapLiteral)
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

    def visit(node : AST::MapEntryDefinition)
      recurse(node.key)
      recurse(node.value)
    end

    def visit(node : AST::ValueInterpolation)
      recurse(node.value)
    end
  end
end
