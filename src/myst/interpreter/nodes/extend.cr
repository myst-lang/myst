module Myst
  class Interpreter
    def visit(node : Extend)
      visit(node.path)
      _module = stack.pop
      unless _module.is_a?(TModule)
        __raise_runtime_error("Cannot extend non-module. Got #{_module}")
      end

      slf = current_self
      if slf.is_a?(TType)
        slf.extend_module(_module)
      else
        __raise_runtime_error("Cannot extend from non-type.")
      end

      # The result of an Extend is the module that was included.
      stack.push(_module)
    end
  end
end
