module Myst
  class Interpreter
    def visit(node : Include)
      visit(node.path)
      _module = stack.pop
      unless _module.is_a?(TModule)
        raise "Cannot include non-module value. Got #{_module}"
      end

      slf = current_self
      if slf.is_a?(ContainerType)
        slf.insert_ancestor(_module)
      else
        raise "Cannot include in non-container type."
      end

      # The result of an Include is the module that was included.
      stack.push(_module)
    end
  end
end
