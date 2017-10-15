module Myst
  class Interpreter
    def visit(node : SimpleAssign)
      node.value.accept(self)
      # The result of the assignment should be the value that is assigned, so
      # it can be left on the stack.
      value = stack.last

      case target = node.target
      when Var
        current_scope.assign(target.name, value)
      when Underscore
        current_scope.assign(target.name, value)
      when IVar
        current_self.ivars[target.name] = value
      when Const
        if current_scope.has_key?(target.name)
          raise "Re-assignment to constant value #{target.name}."
        else
          current_scope.assign(target.name, value)
        end
      else
        # This _should_ never be reached. Assignments to non-assignable values
        # should be caught by the parser.
        raise "Don't know how to assign to #{node.target.class.name}"
      end
    end
  end
end
