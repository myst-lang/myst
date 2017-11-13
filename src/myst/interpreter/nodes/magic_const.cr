module Myst
  class Interpreter
    def visit(node : MagicConst)
      case node.type
      when :file
        stack.push(TString.new(node.file)) if node.location
      when :line
        stack.push(TInteger.new(node.line.to_i64)) if node.location
      end
    end
  end
end
