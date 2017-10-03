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

    # Subtraction with floats will always return a float.
    it_interprets %q(1 - 1.0),      [val(0.0)]
    it_interprets %q(10000 - 0.50), [val(9999.50)]

    # Subtraction with any other type is not supported
    it_does_not_interpret %q(1 - nil),  /invalid argument/
    it_does_not_interpret %q(1 - true), /invalid argument/
    it_does_not_interpret %q(1 - []),   /invalid argument/
    it_does_not_interpret %q(1 - {}),   /invalid argument/
    it_does_not_interpret %q(1 - "a"),  /invalid argument/
    it_does_not_interpret %q(1 - :hi),  /invalid argument/
  end


  describe "#*" do
    it_interprets %q(1 * 1),        [val( 1)]
    it_interprets %q(1 * 2 * 3),    [val( 6)]

    it_interprets %q(10_000 * 100_000), [val(1_000_000_000)]
    it_interprets %q(1234567 * 987654), [val(1_219_325_035_818)]
    # Multiplications are top-truncated
    it_interprets %q(9_223_372_036_854_775_807 * 3),  [val(9_223_372_036_854_775_805)]

    # Multiplication with 0 always yields 0
    it_interprets %q(100 * 0),      [val(0)]
    it_interprets %q(0 * 1234),     [val(0)]

    # Multiplication with floats will always return a float.
    it_interprets %q(1 * 1.0),      [val(1.0)]
    it_interprets %q(10000 * 0.50), [val(5000.0)]

    # Multiplication with any other type is not supported
    it_does_not_interpret %q(1 * nil),  /invalid argument/
    it_does_not_interpret %q(1 * true), /invalid argument/
    it_does_not_interpret %q(1 * []),   /invalid argument/
    it_does_not_interpret %q(1 * {}),   /invalid argument/
    it_does_not_interpret %q(1 * "a"),  /invalid argument/
    it_does_not_interpret %q(1 * :hi),  /invalid argument/
  end


  describe "#/" do
    it_interprets %q(1 / 1),        [val( 1)]
    it_interprets %q(4 / 2 / 2),    [val( 1)]

    it_interprets %q(100_000 / 10_000), [val(10)]
    it_interprets %q(625 / 25),         [val(25)]

    # Division with an Integer is always truncated to return an Integer.
    it_interprets %q(1 / 2),      [val(0)]
    it_interprets %q(10 / 3),     [val(3)]
    it_interprets %q(10 / 4),     [val(2)]

    # Division with a Float does not truncate and always returns a Float.
    it_interprets %q(1 / 2.0),      [val(0.5)]
    it_interprets %q(10 / 3.0),     [val(3.3333333333333335)]
    it_interprets %q(10 / 4.0),     [val(2.5)]

    # Division by any 0 value is invalid
    it_does_not_interpret %q(1 / 0),    /division by zero/
    it_does_not_interpret %q(1 / 0.0),  /division by zero/

    # Division with any other type is not supported
    it_does_not_interpret %q(1 / nil),  /invalid argument/
    it_does_not_interpret %q(1 / true), /invalid argument/
    it_does_not_interpret %q(1 / []),   /invalid argument/
    it_does_not_interpret %q(1 / {}),   /invalid argument/
    it_does_not_interpret %q(1 / "a"),  /invalid argument/
    it_does_not_interpret %q(1 / :hi),  /invalid argument/
  end


  describe "#%" do
    it_interprets %q(1 % 1),        [val( 0)]
    it_interprets %q(7 % 4 % 2),    [val( 1)]

    it_interprets %q(100_000 % 10_000), [val(0)]
    it_interprets %q(625 % 21),         [val(16)]

   # Modulation by a Float will yield a Float.
    it_interprets %q(625 % 21.25),        [val(8.75)]

    # Modulation by 0 is invalid
    it_does_not_interpret %q(1 % 0),    /division by zero/
    it_does_not_interpret %q(1 % 0.0),  /division by zero/

    # Division with any other type is not supported
    it_does_not_interpret %q(1 % nil),  /invalid argument/
    it_does_not_interpret %q(1 % true), /invalid argument/
    it_does_not_interpret %q(1 % []),   /invalid argument/
    it_does_not_interpret %q(1 % {}),   /invalid argument/
    it_does_not_interpret %q(1 % "a"),  /invalid argument/
    it_does_not_interpret %q(1 % :hi),  /invalid argument/
  end


  describe "#to_s" do
    it_interprets %q(1.to_s),         [val("1")]
    it_interprets %q(001.to_s),       [val("1")]
    it_interprets %q(100.to_s),       [val("100")]
    # Underscores in numbers are extracted during lexing. They are not a part
    # of the value itself.
    it_interprets %q(1_234_567.to_s), [val("1234567")]
    it_interprets %q((1 + 1).to_s),   [val("2")]
  end


  describe "#==" do
    it_interprets %q(1  == 1),      [val(true)]
    it_interprets %q(0  == 1),      [val(false)]
    it_interprets %q(1  == 0),      [val(false)]
    it_interprets %q(0  == 0),      [val(true)]

    # Comparing to floats succeeds if the float value is integral.
    it_interprets %q(0 == 0.0),        [val(true)]
    it_interprets %q(1 == 1.0),        [val(true)]
    it_interprets %q(0 == 0.1),        [val(false)]
    it_interprets %q(1 == 1.1),        [val(false)]
    it_interprets %q(1 == 1.000001),   [val(false)]

    it_interprets %q(1  == nil),      [val(false)]
    it_interprets %q(1  == true),     [val(false)]
    it_interprets %q(1  == false),    [val(false)]
    it_interprets %q(1  == "hello"),  [val(false)]
    it_interprets %q(1  == :hi),      [val(false)]
    it_interprets %q(1  == []),       [val(false)]
    it_interprets %q(1  == [1, 2]),   [val(false)]
    it_interprets %q(1  == {}),       [val(false)]
    it_interprets %q(1  == {a: 1}),   [val(false)]
  end

  # Float#!= is the exact inverse of Float#==.
  describe "#!=" do
    it_interprets %q(1  != 1),      [val(false)]
    it_interprets %q(0  != 1),      [val(true)]
    it_interprets %q(1  != 0),      [val(true)]
    it_interprets %q(0  != 0),      [val(false)]

    # Comparing to floats succeeds if the float value is integral.
    it_interprets %q(0  != 0.0),      [val(false)]
    it_interprets %q(1  != 1.0),      [val(false)]
    it_interprets %q(0  != 0.1),      [val(true)]
    it_interprets %q(1  != 1.1),      [val(true)]
    it_interprets %q(1  != 1.000001), [val(true)]

    it_interprets %q(1  != nil),      [val(true)]
    it_interprets %q(1  != true),     [val(true)]
    it_interprets %q(1  != false),    [val(true)]
    it_interprets %q(1  != "hello"),  [val(true)]
    it_interprets %q(1  != :hi),      [val(true)]
    it_interprets %q(1  != []),       [val(true)]
    it_interprets %q(1  != [1, 2]),   [val(true)]
    it_interprets %q(1  != {}),       [val(true)]
    it_interprets %q(1  != {a: 1}),   [val(true)]
  end
end
