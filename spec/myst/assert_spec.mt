require "stdlib/spec.mt"

def test_assert(value)
  value || raise "Test Assertion Failed."
end

def test_raises(&block)
  block()
rescue ex
  test_assert(ex.type.to_s == "AssertionFailure")
end

describe("Assert") do
  describe("Assertion") do
    true_subject  = assert(true)
    false_subject = assert(false)

    describe("#is_truthy") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(true_subject.is_truthy.type.to_s == "Assertion")
      end

      it("passes when the value is anything truthy") do
        test_assert(assert([]).is_truthy.type.to_s == "Assertion")
      end

      it("raises an AssertionFailure if the value is not truthy") do
        test_raises{ false_subject.is_truthy }
      end
    end

    describe("#is_falsey") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(false_subject.is_falsey.type.to_s == "Assertion")
      end


      it("passes when the value is anything nil") do
        test_assert(assert(nil).is_falsey.type.to_s == "Assertion")
      end

      it("raises an AssertionFailure if the value is not truthy") do
        test_raises{ true_subject.is_falsey }
      end
    end

    describe("#is_true") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(true_subject.is_true.type.to_s == "Assertion")
      end

      it("does not pass unless the value is exactly `true`") do
        test_raises{ assert("").is_true }
      end

      it("raises an AssertionFailure if the value is not `true`") do
        test_raises{ false_subject.is_true }
      end
    end

    describe("#is_false") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(false_subject.is_false.type.to_s == "Assertion")
      end

      it("does not pass unless the value is exactly `false`") do
        test_raises{ assert(nil).is_false }
      end

      it("raises an AssertionFailure if the value is not `true`") do
        test_raises{ false_subject.is_false }
      end
    end

    describe("#is_nil") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(assert(nil).is_nil.type.to_s == "Assertion")
      end

      it("raises an AssertionFailure if the value is not `nil`") do
        test_raises{ false_subject.is_nil }
      end
    end

    describe("#is_not_nil") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(assert(true).is_not_nil.type.to_s == "Assertion")
      end

      it("passes when the value is `false`") do
        test_assert(assert(false).is_not_nil.type.to_s == "Assertion")
      end

      it("raises an AssertionFailure if the value is `nil`") do
        test_raises{ assert(nil).is_not_nil }
      end
    end


    describe("#equals") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(assert(true).equals(true).type.to_s == "Assertion")
      end

      it("raises an AssertionFailure if the value is not equal to its argument") do
        test_raises{ assert(true).equals(false) }
      end
    end

    describe("#does_not_equal") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(assert(true).does_not_equal(false).type.to_s == "Assertion")
      end

      it("raises an AssertionFailure if the value is equal to its argument") do
        test_raises{ assert(true).equals(true) }
      end
    end


    describe("#less_than") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(assert(1).less_than(2).type.to_s == "Assertion")
      end

      it("does not pass when the values are equal") do
        test_raises{ assert(1).less_than(1) }
      end

      it("raises an AssertionFailure if the value is not less than its argument") do
        test_raises{ assert(2).less_than(1) }
      end
    end

    describe("#less_or_equal") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(assert(1).less_or_equal(2).type.to_s == "Assertion")
      end

      it("passes when the values are equal") do
        test_assert(assert(1).less_or_equal(1).type.to_s == "Assertion")
      end

      it("raises an AssertionFailure if the value is not less or equal than its argument") do
        test_raises{ assert(2).less_or_equal(1) }
      end
    end

    describe("#greater_or_equal") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(assert(2).greater_or_equal(1).type.to_s == "Assertion")
      end

      it("passes when the values are equal") do
        test_assert(assert(1).greater_or_equal(1).type.to_s == "Assertion")
      end

      it("raises an AssertionFailure if the value is not greater or equal than its argument") do
        test_raises{ assert(1).greater_or_equal(2) }
      end
    end

    describe("#greater_than") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(assert(2).greater_than(1).type.to_s == "Assertion")
      end

      it("does not pass when the values are equal") do
        test_raises{ assert(1).greater_than(1) }
      end

      it("raises an AssertionFailure if the value is not greater than its argument") do
        test_raises{ assert(1).greater_than(1) }
      end
    end


    describe("#between") do
      it("returns the assertion object when the assertion succeeds") do
        test_assert(assert(1).between(0, 2).type.to_s == "Assertion")
      end

      it("passes when the value is equal to the lower argument") do
        test_raises{ assert(1).between(1, 2) }
      end

      it("passes when the value is equal to the upper argument") do
        test_raises{ assert(2).between(1, 2) }
      end

      it("raises an AssertionFailure if the value is not between its arguments") do
        test_raises{ assert(1).between(2, 3) }
      end
    end


    describe("#<") do
      it("acts like #less_than") do
        test_assert(assert(1).less_than(2).type.to_s == "Assertion")
        test_raises{ assert(1).less_than(1) }
        test_raises{ assert(2).less_than(1) }
      end
    end

    describe("#<=") do
      it("acts like #less_or_equal") do
        test_assert(assert(1).less_or_equal(2).type.to_s == "Assertion")
        test_assert(assert(1).less_or_equal(1).type.to_s == "Assertion")
        test_raises{ assert(2).less_or_equal(1) }
      end
    end

    describe("#==") do
      it("acts like #equals") do
        test_assert(assert(true).equals(true).type.to_s == "Assertion")
        test_raises{ assert(true).equals(false) }
      end
    end

    describe("#!=") do
      it("acts like #does_not_equal") do
        test_assert(assert(true).does_not_equal(false).type.to_s == "Assertion")
        test_raises{ assert(true).equals(true) }
      end
    end

    describe("#>=") do
      it("acts like #greater_or_equal") do
        test_assert(assert(2).greater_or_equal(1).type.to_s == "Assertion")
        test_assert(assert(1).greater_or_equal(1).type.to_s == "Assertion")
        test_raises{ assert(1).greater_or_equal(2) }
      end
    end

    describe("#>") do
      it("acts like #greater_than") do
        test_assert(assert(2).greater_than(1).type.to_s == "Assertion")
        test_raises{ assert(1).greater_than(1) }
        test_raises{ assert(1).greater_than(1) }
      end
    end
  end



  describe("BlockAssertion") do
    raising_subject = assert{ raise :foo }
    passing_subject = assert{ :passing }

    describe("#raises") do
      describe("with no arguments") do
        it("returns the blockassertion object when the block raises any error") do
          test_assert(raising_subject.raises.type.to_s == "BlockAssertion")
        end

        it("raises an AssertionFailure when the block does not raise an error") do
          test_raises{ passing_subject.raises }
        end
      end

      describe("with an error argument") do
        it("returns the blockassertion object if the block raises the given error") do
          test_assert(raising_subject.raises(:foo).type.to_s == "BlockAssertion")
        end

        it("raises an AssertionFailure when the block does not raise an error") do
          test_raises{ passing_subject.raises(:foo) }
        end

        it("raises an AssertionFailure when the block does not raise a matching error") do
          test_raises{ raising_subject.raises(:bar) }
        end
      end
    end

    describe("#succeeds") do
      it("returns the blockassertion object when the block does not raise an error") do
        test_assert(passing_subject.succeeds.type.to_s == "BlockAssertion")
      end

      it("raises an AssertionFailure when the block does raise an error") do
        test_raises{ raising_subject.succeeds }
      end
    end

    describe("#returns") do
      it("returns the blockassertion object when the block returns the expected value") do
        test_assert(passing_subject.returns(:passing).type.to_s == "BlockAssertion")
      end

      it("raises an AssertionFailure when the block does not return the expected value") do
        test_raises{ passing_subject.returns(:foo) }
      end

      it("raises an AssertionFailure when the block raises an error") do
        test_raises{ raising_subject.returns(:passing) }
      end
    end

    describe("#called_with_arguments") do
      it("sets the arguments to be used when calling the block in an assertion") do
        passed_args = []
        assert{ |*args| passed_args = args }.called_with_arguments(1, 2).succeeds

        test_assert(passed_args == [1, 2])
      end
    end
  end
end
