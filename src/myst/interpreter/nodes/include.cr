module Myst
  class Interpreter
    def visit(node : Include)
      visit(node.path)
      _module = stack.pop
      unless _module.is_a?(TModule)
        raise "Cannot include non-module value. Got #{_module}"
      end

      current_self.insert_ancestor(_module)

      # The result of an Include is the module that was included.
      stack.push(_module)
    end
  end
end
