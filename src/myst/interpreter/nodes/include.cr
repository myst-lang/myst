module Myst
  class Interpreter
    def visit(node : Include)
      # Includes are only valid on a Module or Type. Attempting to include a
      # module on an instance, for example, is not allowed.
      unless current_self.is_a?(TModule) || current_self.is_a?(TType)
        raise "Include is not allowed on a #{current_self.type_name}. Must either be a Module or a Type."
      end

      visit(node.path)
      _module = stack.pop
      unless _module.is_a?(TModule)
        raise "Cannot include non-module value. Got #{_module}"
      end

      case slf = current_self
      when TType
        # Includes on Types will include the module in the instance scope for
        # the Type, rather than the static scope.
        slf.instance_scope.insert_parent(_module.scope)
      else
        slf.scope.insert_parent(_module.scope)
      end

      # The result of an Include is the module that was included.
      stack.push(_module)
    end
  end
end
