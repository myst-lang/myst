module Myst
  class ControlException < Exception
  end

  class ReturnException < ControlException; end
  class BreakException  < ControlException; end
  class NextException   < ControlException; end
end
