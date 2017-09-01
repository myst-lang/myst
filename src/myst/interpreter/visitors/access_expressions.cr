class Myst::Interpreter
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
        raise "Unknown member `#{member_name}` for primitive value `#{receiver.type_name}`."
      end
    else
      raise "#{receiver} does not allow member access."
    end
  end

  def visit(node : AST::MemberAssignmentExpression)
    recurse(node.receiver)
    receiver = stack.pop
    member_name = node.member
    recurse(node.value)
    value = stack.pop

    case receiver
    when TObject, Scope
      stack.push(receiver[member_name] = value)
    else
      raise "#{receiver} does not allow member assignment."
    end
  end
end
