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
    property  trace : Callstack

    def initialize(@value : Value, @trace : Callstack)
    end
  end

  # These subclasses of RuntimeError help clean up the interpreter source code
  # to better show the intent of the raised errors, and ensure consistency
  # between them.
  class MatchError < RuntimeError
    def initialize(@trace : Callstack, message : String = "match failure")
      @value = TString.new(message)
    end
  end
end
