class Myst::Interpreter
  class ControlException  < Exception; end
  class ReturnException   < ControlException; end
  class NextException     < ControlException; end
  class BreakException    < ControlException
    property? caught = false
  end
end
