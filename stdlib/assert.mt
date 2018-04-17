#doc Assert
#| The `Assert` module provides an interface for making assertions about Myst
#| code and values.
#|
#| Interacting with this module is primarily done through the top-level
#| `assert` method, providing either a value or code block to use as the
#| subject of the assertions. This method wraps that value or code block into
#| an assertion object (either `Assertion` or `BlockAssertion`), which is then
#| used to actually perform the assertions.
#|
#| This module is designed with a fluid interface to simplify writing multiple
#| assertions on the same subject. Every assertion method returns `self` when
#| it succeeds or raises an Error when it fails, meaning assertions can easily
#| be chained together.
#|
#| As a contrived example, `assert().between(a, b)` could also be written as
#| two separate assertions chained together:
#| `assert().greater_or_equal(a).less_or_equal(b)`.
#|
#| This module is primarily intended for use with the `Spec` module to write
#| tests, but it also available for use by application code in cases where
#| complex assertions about data are needed. That said, the language itself
#| often provides cleaner, more idiomatic ways of making similar assertions
#| that should be preferred (e.g. pattern matching, multiple function clauses,
#| `match` expressions, etc.).
defmodule Assert
  #doc AssertionFailure
  #| An AssertionFailure is a container object that is raised when an assertion
  #| fails to complete.
  deftype AssertionFailure
    def initialize(@left, @right, @message : String); end
    def initialize(@left, @right)
      @message = ""
    end

    def left; @left; end
    def right; @right; end

    def to_s
      "Assertion failed: `<(@message)>`\n" +
      "     left: <(@left)>\n" +
      "    right: <(@right)>\n"
    end
  end


  #doc Assertion
  #| An object representing a pending assertion for a static value.
  #| Instantiating an `Assertion` object only stores the "left-hand" value.
  #| Making actual assertions is done with the instance methods on the object.
  #| For example, equality can be asserted with `%Assertion{true}.equals(true)`.
  #|
  #| When an assertion succeeds, the method will return normally, but if the
  #| assertion fails, the method will raise an `AssertionFailure` object with
  #| information about the failure.
  deftype Assertion
    def initialize(@value); end

    #doc is_truthy -> self
    #| Asserts that the value is truthy (not `false` or `nil`).
    def is_truthy
      @value || raise %AssertionFailure{@value, true, "truthy"}
      self
    end

    #doc is_falsey -> self
    #| Asserts that the value is falsey (either `false` or `nil`).
    def is_falsey
      @value && raise %AssertionFailure{@value, false, "falsey"}
      self
    end

    #doc is_true -> self
    #| Asserts that the value is exactly the boolean value `true`.
    def is_true
      @value == true || raise %AssertionFailure{@value, true, "exactly true"}
      self
    end

    #doc is_false -> self
    #| Asserts that the value is exactly the boolean value `false`.
    def is_false
      @value == false || raise %AssertionFailure{@value, false, "exactly false"}
      self
    end

    #doc is_nil -> self
    #| Asserts that the value is `nil` (false is not allowed).
    def is_nil
      @value == nil || raise %AssertionFailure{@value, nil, "nil"}
      self
    end

    #doc is_not_nil -> self
    #| Asserts that the value is not `nil` (false is allowed).
    def is_not_nil
      @value != nil || raise %AssertionFailure{@value, nil, "not nil"}
      self
    end


    #doc equals(other) -> self
    #| Assert that the value is equal to `other` using its `==` method.
    def equals(other)
      unless @value == other
        raise %AssertionFailure{@value, other, "left == right"}
      end

      self
    end

    #doc does_not_equal(other) -> self
    #| Assert that the value is not equal to `other` using its `!=` method.
    def does_not_equal(other)
      unless @value != other
        raise %AssertionFailure{@value, other, "left != right"}
      end

      self
    end

    #doc less_than(other) -> self
    #| Assert that the value is less than `other` using its `<` method.
    def less_than(other)
      unless @value < other
        raise %AssertionFailure{@value, other, "left < right"}
      end

      self
    end

    #doc less_or_equal(other) -> self
    #| Assert that the value is less than or equal to `other` using its `<=`
    #| method.
    def less_or_equal(other)
      unless @value <= other
        raise %AssertionFailure{@value, other, "left <= right"}
      end

      self
    end

    #doc greater_or_equal(other) -> self
    #| Assert that the value is greater than or equal to `other` using its `>=`
    #| method.
    def greater_or_equal(other)
      unless @value >= other
        raise %AssertionFailure{@value, other, "left >= right"}
      end

      self
    end

    #doc greater_than(other) -> self
    #| Assert that the value is greater than `other` using its `>` method.
    def greater_than(other)
      unless @value > other
        raise %AssertionFailure{@value, other, "left > right"}
      end

      self
    end

    #doc between(lower, upper) -> self
    #| Assert that the value is between `lower` and `upper` (inclusively), using
    #| only the `<=`operator on the value for comparisons.
    def between(lower, upper)
      unless lower <= @value && @value <= upper
        raise %AssertionFailure{@value, [lower, upper], "lower <= value <= upper"}
      end

      self
    end

    #doc <(other) -> self
    #| Operator alias for `less_than(other)`.
    def <(other)
      less_than(other)
    end

    #doc <=(other) -> self
    #| Operator alias for `less_or_equal(other)`.
    def <=(other)
      less_or_equal(other)
    end

    #doc ==(other) -> self
    #| Operator alias for `equals(other)`.
    def ==(other)
      equals(other)
    end

    #doc <=(other) -> self
    #| Operator alias for `does_not_equal(other)`.
    def !=(other)
      does_not_equal(other)
    end

    #doc >=(other) -> self
    #| Operator alias for `greater_or_equal(other)`.
    def >=(other)
      greater_or_equal(other)
    end

    #doc >(other) -> self
    #| Operator alias for `greater_than(other)`.
    def >(other)
      greater_than(other)
    end

    #doc is_a(other : Type) -> self
    #| Assert that the value is an instance of `type`.
    def is_a(other : Type)
      unless [@value.type, *@value.type.ancestors].any?{ |anc| anc == other }
        raise %AssertionFailure{
          "<(@value.type)> (<(@value.ancestors.map{ |t| t.to_s }.join(","))>)",
          other,
          "value is not an instance or subtype of <(other)>"
        }
      end
    end

    #doc includes(element) -> self
    #| Assert that the value includes `element`. This requires that the value
    #| is Enumerable (implements `#each`)
    def includes(element)
      unless @value.any?{ |e| e == element }
        raise %AssertionFailure{@value, element, "value does not include the requested element"}
      end
    end
  end


  #doc BlockAssertion
  #| An object representing a pending assertion for a block of code. Similar to
  #| the regular `Assertion`, instantiating a `BlockAssertion` only stores the
  #| block of code to be run when making the assertion. Making the actual
  #| assertion is done by calling methods on the resulting object.
  #|
  #| `BlockAssertion` is most useful for asserting that running a code block
  #| has a specific side effect, namely raising errors.
  deftype BlockAssertion
    def initialize(@block)
      @arguments_for_call = []
    end

    #doc raises(expected_error=nil) -> self
    #| Assert that calling the block raises an error with the given value. If
    #| no value is given, the assertion just checks that an error is raised.
    #|
    #| The block will be called with whatever arguments have been set with
    #| `called_with_arguments`. By default, no arguments will be given.
    def raises(expected_error)
      @block(*@arguments_for_call)
      raise %AssertionFailure{"block(<(@arguments_for_call.join(", "))>)", expected_error, "expected the block to raise an error"}
    rescue <expected_error>
      # If this rescue matches, the block must have raised a matching error,
      # so the assertion is successful.
      self
    rescue ex : AssertionFailure
      raise ex
    rescue actual_error
      # If any other error is raised, the assertion has not passed. This block
      # provides a more helpful message containing the actual and expected errors.
      raise %AssertionFailure{expected_error, actual_error, "error from block did not match expected"}
    end

    def raises
      block(*@arguments_for_call)
      raise %AssertionFailure{"block(<(@arguments_for_call.join(", "))>)", "any error", "expected the block to raise an error"}
    rescue ex : AssertionFailure
      # If the assertion failure is what's being raised, pass it through.
      raise ex
    rescue
      # Otherwise, if this rescue matches, the block must have raised a
      # matching error, so the assertion is successful.
      self
    end

    #doc succeeds -> self
    #| Assert that calling the block completes successfully (does not raise an
    #| error).
    def succeeds
      @block(*@arguments_for_call)
      self
    rescue err
      raise %AssertionFailure{"block(<(@arguments_for_call.join(", "))>)", err, "expected no error from block"}
    end

    #doc returns(value) -> self
    #| Assert that calling the block returns the given value.
    def returns(expected_result)
      unless @block(*@arguments_for_call) == expected_result
        raise %AssertionFailure{"block(<(@arguments_for_call.join(", "))>)", expected_result, "return value from block did not match expected value"}
      end

      self
    rescue err
      raise %AssertionFailure{"block(<(@arguments_for_call.join(", "))>)", err, "expected no error from block"}
    end

    #doc called_with_arguments(*args) -> self
    #| Set the arguments to be used when calling the block for an assertion.
    def called_with_arguments(*args)
      @arguments_for_call = args
      self
    end
  end
end



#doc assert(&block?) -> assertion object
#| The global entrypoint to writing assertions. `assert` accepts any value or
#| block as an argument, and returns the appropriate assertion object to write
#| assertions with.
def assert(value)
  %Assert.Assertion{value}
end
def assert(&block)
  %Assert.BlockAssertion{block}
end
