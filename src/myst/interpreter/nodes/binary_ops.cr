module Myst
  class Interpreter
    # And and Or are both short-circuiting operations. If the left side is
    # enough to determine the result of the expression, the right side will
    # not be evaluated.

    # The result of either expression, in any case, will be the value that
    # determined the result. i.e., in the expression `true && false`, the
    # result will be `false`, while `nil && false` will result in `nil`.
    def visit(node : And)
      node.left.accept(self)

      if stack.last.truthy?
        stack.pop
        node.right.accept(self)
      end
    end

    def visit(node : Or)
      node.left.accept(self)

      unless stack.last.truthy?
        stack.pop
        node.right.accept(self)
      end
    end
  end
end
