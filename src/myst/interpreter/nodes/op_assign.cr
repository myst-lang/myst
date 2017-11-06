module Myst
  class Interpreter
    def visit(node : OpAssign)
      # Conditional assignments have a different rewritten form than normal
      # OpAssigns. Instead of `a = a op b`, they are rewritten to a rough
      # equivalent of `a op a = b`.
      op_without_assign = node.op[0..-2]

      case node.op
      when "||="
        visit_or_assign(node)
      when "&&="
        visit_and_assign(node)
      else
        visit(
          SimpleAssign.new(
            node.target,
            Call.new(node.target, op_without_assign, [node.value]).at(node)
          ).at(node)
        )
      end
    end


    def visit_or_assign(node : OpAssign)
      # Vars, Underscores, and Consts will all raise an error if the name
      # does not yet exist in the scope, so they should be created in
      # advance with a `nil` value to ensure that an assignment happens.
      target = node.target
      should_assign =
        case target
        when StaticAssignable
          if existing_value = current_scope[target.name]?
            !existing_value.truthy?
          else
            true
          end
        else
          visit(target)
          value = stack.pop
          !value.truthy?
        end

      return unless should_assign


      rewrite =
        # Calls can not get re-written as SimpleAssigns. Although the syntactic
        # expansion is the same, the parser handles Calls specially to modify
        # the name of the method, rather than create a SimpleAssign. That is
        # simply replicated here.
        if target.is_a?(Call)
          # Equivalent to `receiver.method=(value)
          Call.new(target.receiver?, "#{target.name}=", [node.value], nil, infix: false)
        else
          SimpleAssign.new(node.target, node.value).at(node)
        end

      visit(rewrite)
    end


    def visit_and_assign(node : OpAssign)
      # Vars, Underscores, and Consts will all raise an error if the name
      # does not yet exist in the scope, so they should be created in
      # advance with a `nil` value to ensure that an assignment happens.
      target = node.target
      should_assign =
        case target
        when StaticAssignable
          if existing_value = current_scope[target.name]?
            existing_value.truthy?
          else
            # If the current scope does not contain the requested name, it
            # should be created with a default value of `nil`. This will still
            # avoid doing the assignment, but ensures that the variable exists.
            current_scope.assign(target.name, TNil.new)
            false
          end
        else
          visit(target)
          value = stack.pop
          value.truthy?
        end

      return unless should_assign


      rewrite =
        # Calls can not get re-written as SimpleAssigns. Although the syntactic
        # expansion is the same, the parser handles Calls specially to modify
        # the name of the method, rather than create a SimpleAssign. That is
        # simply replicated here.
        if target.is_a?(Call)
          # Equivalent to `receiver.method=(value)
          Call.new(target.receiver?, "#{target.name}=", [node.value], nil, infix: false).at(node)
        else
          SimpleAssign.new(node.target, node.value).at(node)
        end

      visit(rewrite)
    end
  end
end
