require "../calculator.cr"

class Myst::Interpreter
  def visit(node : AST::LogicalExpression)
    case node.operator.type
    when Token::Type::ANDAND
      recurse(node.left)
      return unless stack.last.truthy?
      stack.pop
      # Recursing the right node should leave it's result on the stack
      recurse(node.right)
    when Token::Type::OROR
      recurse(node.left)
      return if stack.last.truthy?
      stack.pop
      # Recursing the right node should leave it's result on the stack
      recurse(node.right)
    end
  end

  def visit(node : AST::EqualityExpression | AST::RelationalExpression | AST::BinaryExpression)
    recurse(node.left)
    recurse(node.right)

    b = stack.pop
    a = stack.pop

    stack.push(Calculator.do(node.operator.type, a, b))
  end
end
