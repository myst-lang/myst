module Myst
  class Interpreter
    def visit(node : MagicConst)
      case node.type
      when :"__FILE__"
        stack.push(TString.new(node.file))
      when :"__LINE__"
        stack.push(TInteger.new(node.line.to_i64))
      when :"__DIR__"
        stack.push(TString.new(node.dir))
      end
    end
  end
end
