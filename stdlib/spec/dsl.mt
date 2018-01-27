defmodule Spec
  defmodule DSL
    def assert(assertion)
      unless assertion
        raise %AssertionFailure{true, assertion}
      end
    end

    def refute(assertion)
      when assertion
        raise %AssertionFailure{false, assertion}
      end
    end

    # Expect the given block to raise an error matching the given value. If no
    # error, or an error with a different value, is raised, the assertion fails.
    def expect_raises(expected_error, &block)
      block()
      raise %AssertionFailure{expected_error, "no error"}
    rescue <expected_error>
      # If the raised error matches what was expected, the assertion passes.
    rescue received_error
      # For any other error
      raise %AssertionFailure{expected_error, received_error}
    end

    # Same as `expect_raises(expected, &block)`, but without the expectation of
    # a specific error.
    def expect_raises(&block)
      block()
      raise %AssertionFailure{"Any Error", "no error"}
    rescue ex : AssertionFailure
      # Rescuing an AssertionFailure implies that `block` did
      # not raise an exception, so the exception is re-raised.
      raise ex
    rescue
      # Otherwise, the error must have come from `block`, so the
      # assertion is successful.
    end
  end
end
