module Myst
  class Interpreter
    def visit(node : MagicConst)
      case node.type
      when :"__FILE__"
        stack.push(node.file)
      when :"__LINE__"
        stack.push(node.line.to_i64)
      when :"__DIR__"
        stack.push(node.dir)
      end
    end
  end
end
