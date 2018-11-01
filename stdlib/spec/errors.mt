require "./single_spec.mt"

defmodule Spec
  #doc AssertionFailure
  #| An AssertionFailure is a container object that is raised when an assertion
  #| made within an `it` block fails. The failure contains the Spec object that
  #| failed, the value that was expected, and the value that was received.
  deftype AssertionFailure
    def initialize(expected, got)
      @expected = expected
      @got      = got
    end

    def expected; @expected;  end
    def got;      @got;       end

    def to_s : String
      "Assertion failed.\n" +
      "    Expected: <(@expected)>\n" +
      "         Got: <(@got)>\n"
    end
  end
end
