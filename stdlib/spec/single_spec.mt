defmodule Spec
  deftype SingleSpec
    def initialize(name : String)
      @name = name
      @container = nil
    end

    def name; @name; end

    def run(&block)
      block()
      IO.print(".")
    rescue failure
      IO.puts(failure)
      exit(1)
    end


    def assert(assertion)
      unless assertion
        raise %AssertionFailure{@name, true, assertion}
      end
    end

    def refute(assertion)
      when assertion
        raise %AssertionFailure{@name, false, assertion}
      end
    end

    # Expect the given block to raise an error matching the given value. If no
    # error, or an error with a different value, is raised, the assertion fails.
    def expect_raises(expected_error, &block)
      block()
      raise %AssertionFailure{@name, expected_error, "no error"}
    rescue <expected_error>
      # If the raised error matches what was expected, the assertion passes.
    rescue received_error
      # For any other error
      raise %AssertionFailure{@name, expected_error, received_error}
    end

    # Same as `expect_raises(expected, &block)`, but without the expectation of
    # a specific error.
    def expect_raises(&block)
      block()
      raise %AssertionFailure{@name, "Any Error", "no error"}
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
