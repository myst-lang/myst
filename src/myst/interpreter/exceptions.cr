module Myst
  class ControlException < Exception
    property? caught : Bool = false
  end

  class ReturnException < ControlException; end
  class BreakException  < ControlException; end
  class NextException   < ControlException; end
end
