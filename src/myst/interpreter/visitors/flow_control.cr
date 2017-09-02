require "pretty_print"

class Myst::Interpreter
  # Handling flow control is done by raising an exception that will be rescued
  # later on by the nodes that deal with flow control. The value to be returned
  # by the statement is carried on the top of the stack.
  class FlowControlException < Exception
    property? uncaught : Bool = true
  end

  class BreakException  < FlowControlException; end
  class ReturnException < FlowControlException; end
  class NextException   < FlowControlException; end


  def visit(node : AST::ReturnStatement)
    push_flow_control_value(node.value)
    raise ReturnException.new
  end

  def visit(node : AST::BreakStatement)
    push_flow_control_value(node.value)
    raise BreakException.new
  end

  def visit(node : AST::NextStatement)
    push_flow_control_value(node.value)
    raise NextException.new
  end

  private def push_flow_control_value(node : AST::Node?)
    if node
      recurse(node)
    else
      stack.push(TNil.new)
    end
  end
end

