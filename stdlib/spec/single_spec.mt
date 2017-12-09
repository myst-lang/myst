defmodule Spec
  deftype SingleSpec
    def initialize(name : String)
      @name = name
      @container = nil
    end

    def name; @name; end

    def run(&block)
      block()
      IO.puts(".")
    rescue failure
      IO.puts(failure)
      exit(1)
    end


    def assert(assertion)
      unless assertion
        raise %AssertionFailure{@name, true, assertion}
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
      raise %AssertionFailure{@name, expected_error, "no error"}
    rescue
      # If an error was raised, the assertion passes.
    end
  end
end
