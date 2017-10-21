module Myst
  # ControlExceptions are implementation-level exceptions used by the
  # interpreter, not meant for use in language-level code.
  #
  # Any exception raised inside of the language (via `raise` or by the
  # interpreter) will be a descendant of RuntimeError.
  class ControlException < Exception
    property? caught : Bool = false
  end

  class ReturnException < ControlException; end
  class BreakException  < ControlException; end
  class NextException   < ControlException; end

  # The containing error type for any error raised within the language.
  class RuntimeError < Exception
    property  value : Value

    def initialize(@value : Value)
    end
  end
end
