module Myst
  class Interpreter
    def visit(node : SimpleAssign)
      node.value.accept(self)
      # The result of the assignment should be the value that is assigned, so
      # it can be left on the stack.
      value = stack.last

      case target = node.target
      when Var
        @symbol_table[target.name] = value
      when Underscore
        @symbol_table[target.name] = value
      when Const
        if @symbol_table[target.name]?
          raise "Re-assignment to constant value #{target.name}."
        else
          @symbol_table[target.name] = value
        end
      else
        # This _should_ never be reached. Assignments to non-assignable values
        # should be caught by the parser.
        raise "Don't know how to assign to #{node.target.class.name}"
      end
    end
  end
end
