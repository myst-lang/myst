require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - Integer Methods" do
  describe "#+" do
    it_interprets %q(1 + 1),        [val(2)]
    it_interprets %q(1 + 1 + 1),    [val(3)]

    it_interprets %q(10_000 + 100_000),               [val(110_000)]
    it_interprets %q(1234567890 + 987654310),         [val(2_222_222_200)]
    # Additions around max int wrap around to negatives.
    it_interprets %q(9_223_372_036_854_775_807 + 1),  [val(-9_223_372_036_854_775_808)]

    # Addition with 0 does nothing
    it_interprets %q(0 + 100),      [val(100)]
    it_interprets %q(100 + 0),      [val(100)]
    it_interprets %q(10 + 0 + 10),  [val( 20)]
    it_interprets %q(0 + 100 + 0),  [val(100)]

    # Addition with floats will always return a float.
    it_interprets %q(1 + 1.0),      [val(2.0)]
    it_interprets %q(123 + 12_396_851_265_129.468), [val(12_396_851_265_252.468)]

    # Addition with any other type is not supported
    it_does_not_interpret %q(1 + nil),  /invalid argument/
    it_does_not_interpret %q(1 + true), /invalid argument/
    it_does_not_interpret %q(1 + []),   /invalid argument/
    it_does_not_interpret %q(1 + {}),   /invalid argument/
    it_does_not_interpret %q(1 + "a"),  /invalid argument/
    it_does_not_interpret %q(1 + :hi),  /invalid argument/
  end

  describe "#-" do
    it_interprets %q(1 - 1),        [val( 0)]
    # Arithmetic should be left-associative
    it_interprets %q(1 - 1 - 1),    [val(-1)]
    it_interprets %q(2 - 1),        [val( 1)]

    it_interprets %q(10_000 - 100_000),               [val(-90_000)]
    it_interprets %q(1234567890 - 987654310),         [val(246_913_580)]
    # Subtractions around min int wrap around to positives.
    it_interprets %q(0 - 9_223_372_036_854_775_807 - 2),  [val(9_223_372_036_854_775_807)]

    # Subtraction with 0 does nothing
    it_interprets %q(100 - 0),      [val(100)]
    it_interprets %q(10 - 0 - 0),   [val( 10)]
    # Subtraction from 0 acts like negation
    it_interprets %q(0 - 100),      [val(-100)]

    # Addition with floats will always return a float.
    it_interprets %q(1 - 1.0),      [val(0.0)]
    it_interprets %q(10000 - 0.50), [val(9999.50)]

    # Addition with any other type is not supported
    it_does_not_interpret %q(1 - nil),  /invalid argument/
    it_does_not_interpret %q(1 - true), /invalid argument/
    it_does_not_interpret %q(1 - []),   /invalid argument/
    it_does_not_interpret %q(1 - {}),   /invalid argument/
    it_does_not_interpret %q(1 - "a"),  /invalid argument/
    it_does_not_interpret %q(1 - :hi),  /invalid argument/
  end


  describe "#to_s" do
    it_interprets %q(1.to_s),         [val("1")]
    # Underscores in numbers are extracted during lexing. They are not a part
    # of the value itself.
    it_interprets %q(1_234_567.to_s), [val("1234567")]
    it_interprets %q((1 + 1).to_s),   [val("2")]
  end
end
