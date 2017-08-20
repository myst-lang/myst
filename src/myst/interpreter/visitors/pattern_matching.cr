require "../matcher.cr"

class Myst::Interpreter
  def visit(node : AST::PatternMatchingAssignment)
    recurse(node.value)
    result = Matcher.new(self).match(node.pattern, stack.pop)
    stack.push(result)
  end
end
