require "../../spec_helper.cr"
require "../../support/interpret.cr"

describe "NativeLib - Random methods" do
  describe "#rand" do
    describe "without arguments" do
      it "returns a Float" do
        itr = parse_and_interpret %q(
          Random.rand()
        )

        rand_result = itr.stack.last.should be_a(TFloat)
      end

      it "returns a value in the range of [0, 1]" do
        itr = parse_and_interpret %q(
          Random.rand()
        )

        (0_f64..1_f64).should contain(itr.stack.last.as(TFloat).value)
      end
    end

    describe "with an Integer argument" do
      it "returns an Integer value" do
        itr = parse_and_interpret %q(
          Random.rand(500)
        )

        itr.stack.last.should be_a(TInteger)
      end

      it "returns a value smaller than the given maximum" do
        itr = parse_and_interpret %q(
          Random.rand(500)
        )

        (0..500).should contain(itr.stack.last.as(TInteger).value)
      end
    end

    describe "with a Float argument" do
      it "returns a Float value" do
        itr = parse_and_interpret %q(
          Random.rand(500.0)
        )

        itr.stack.last.should be_a(TFloat)
      end

      it "returns a value smaller than the given maximum" do
        itr = parse_and_interpret %q(
          Random.rand(500.0)
        )

        (0_f64..500_f64).should contain(itr.stack.last.as(TFloat).value)
      end
    end
  end
end
