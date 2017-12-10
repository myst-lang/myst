require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - Float Methods" do
  describe "#+" do
    it_interprets %q(1.0 + 1.0),        [val(2.0)]
    it_interprets %q(1.0 + 1.0 + 1.0),  [val(3.0)]

    it_interprets %q(100.500 + 500.800),              [val(601.300)]
    it_interprets %q(123456.7880 + 987654.310),       [val(1_111_111.098)]

    # Addition with 0 does nothing
    it_interprets %q(0.0 + 100.0),        [val(100.0)]
    it_interprets %q(100.0 + 0.0),        [val(100.0)]
    it_interprets %q(10.0 + 0.0 + 10.0),  [val( 20.0)]
    it_interprets %q(0.0 + 100.0 + 0.0),  [val(100.0)]

    # Addition with floats will always return a float.
    it_interprets %q(1.0 + 1), [val(2.0)]
    it_interprets %q(12_396_851_265_129.468 + 123), [val(12_396_851_265_252.468)]

    # Addition with any other type is not supported
    it_does_not_interpret %q(1.0 + nil),  /invalid argument/
    it_does_not_interpret %q(1.0 + true), /invalid argument/
    it_does_not_interpret %q(1.0 + []),   /invalid argument/
    it_does_not_interpret %q(1.0 + {}),   /invalid argument/
    it_does_not_interpret %q(1.0 + "a"),  /invalid argument/
    it_does_not_interpret %q(1.0 + :hi),  /invalid argument/
  end


  describe "#-" do
    it_interprets %q(1.0 - 1.0),        [val( 0.0)]
    it_interprets %q(1.0 - 1.0 - 1.0),  [val(-1.0)]

    it_interprets %q(100.500 - 500.800),              [val(-400.300)]
    it_interprets %q(123456.7880 - 987654.410),       [val(-864_197.622)]

    it_interprets %q(0.0 - 100.0),        [val(-100.0)]
    it_interprets %q(100.0 - 0.0),        [val( 100.0)]
    it_interprets %q(10.0 - 0.0 - 10.0),  [val(   0.0)]
    it_interprets %q(0.0 - 100.0 - 0.0),  [val(-100.0)]

    # Addition with floats will always return a float.
    it_interprets %q(1.0 - 1), [val(0.0)]
    it_interprets %q(12_396_851_265_129.468 - 123), [val(12_396_851_265_006.468)]

    # Addition with any other type is not supported
    it_does_not_interpret %q(1.0 - nil),  /invalid argument/
    it_does_not_interpret %q(1.0 - true), /invalid argument/
    it_does_not_interpret %q(1.0 - []),   /invalid argument/
    it_does_not_interpret %q(1.0 - {}),   /invalid argument/
    it_does_not_interpret %q(1.0 - "a"),  /invalid argument/
    it_does_not_interpret %q(1.0 - :hi),  /invalid argument/
  end


  describe "#*" do
    it_interprets %q(1.0 * 1.0),        [val(1.0)]
    it_interprets %q(1.0 * 2.0 * 3.0),  [val(6.0)]

    it_interprets %q(100.500 * 500.800),              [val(50_330.400)]
    it_interprets %q(123456.7880 * 987654.310),       [val(121_932_628_766.95628)]

    # Multiplication with 0 always yields 0
    it_interprets %q(100.0 * 0),      [val(0.0)]
    it_interprets %q(0 * 1234.0),     [val(0.0)]

    # Multiplication with integers will always return a float.
    it_interprets %q(1.0 * 1),      [val(1.0)]
    it_interprets %q(10000.0 * 2),  [val(20000.0)]

    # Multiplication with any other type is not supported
    it_does_not_interpret %q(1.0 * nil),  /invalid argument/
    it_does_not_interpret %q(1.0 * true), /invalid argument/
    it_does_not_interpret %q(1.0 * []),   /invalid argument/
    it_does_not_interpret %q(1.0 * {}),   /invalid argument/
    it_does_not_interpret %q(1.0 * "a"),  /invalid argument/
    it_does_not_interpret %q(1.0 * :hi),  /invalid argument/
  end


  describe "#/" do
    it_interprets %q(1.0 / 1.0),        [val(1.0)]
    it_interprets %q(4.0 / 2.0 / 2.0),  [val(1.0)]

    it_interprets %q(100_000.0 / 10_000.0), [val(10.0)]
    it_interprets %q(625.0 / 20.0),         [val(31.25)]

    # Division with a Float does not truncate and always returns a Float.
    it_interprets %q(1.0 / 2),    [val(0.5)]
    it_interprets %q(10.0 / 3),     [val(3.3333333333333335)]
    it_interprets %q(10.0 / 4),     [val(2.5)]

    # Division by any 0 value is invalid
    it_does_not_interpret %q(1.0 / 0),    /division by zero/
    it_does_not_interpret %q(1.0 / 0.0),  /division by zero/

    # Division with any other type is not supported
    it_does_not_interpret %q(1.0 / nil),  /invalid argument/
    it_does_not_interpret %q(1.0 / true), /invalid argument/
    it_does_not_interpret %q(1.0 / []),   /invalid argument/
    it_does_not_interpret %q(1.0 / {}),   /invalid argument/
    it_does_not_interpret %q(1.0 / "a"),  /invalid argument/
    it_does_not_interpret %q(1.0 / :hi),  /invalid argument/
  end


  describe "#%" do
    it_interprets %q(1.0 % 1.0),            [val(0.0)]

    it_interprets %q(100_000.0 % 10_000.0), [val(0.0)]
    it_interprets %q(625.0 % 21.25),        [val(8.75)]

    # Modulation by 0 is invalid
    it_does_not_interpret %q(1.0 % 0),    /division by zero/
    it_does_not_interpret %q(1.0 % 0.0),    /division by zero/

    # Division with any other type is not supported
    it_does_not_interpret %q(1.0 % nil),  /invalid argument/
    it_does_not_interpret %q(1.0 % true), /invalid argument/
    it_does_not_interpret %q(1.0 % []),   /invalid argument/
    it_does_not_interpret %q(1.0 % {}),   /invalid argument/
    it_does_not_interpret %q(1.0 % "a"),  /invalid argument/
    it_does_not_interpret %q(1.0 % :hi),  /invalid argument/
  end


  describe "#to_s" do
    it_interprets %q(1.0.to_s),             [val("1.0")]
    it_interprets %q(123.456.to_s),         [val("123.456")]
    # Insignificant 0s are stripped from the value.
    it_interprets %q(00123.45600.to_s),     [val("123.456")]
    # Underscores in numbers are extracted during lexing. They are not a part
    # of the value itself.
    it_interprets %q(1_234_567.00.to_s),    [val("1234567.0")]
    it_interprets %q((1.0 + 1.0).to_s),     [val("2.0")]
  end


  describe "#==" do
    it_interprets %q(1.0  == 1.0),      [val(true)]
    it_interprets %q(0.5  == 1.0),      [val(false)]
    it_interprets %q(1.0  == 0.5),      [val(false)]
    it_interprets %q(1.0  == 1.00001),  [val(false)]
    it_interprets %q(0.0  == 0.0),      [val(true)]

    # Comparing to integers succeeds if the float value is integral.
    it_interprets %q(0.0  == 0),        [val(true)]
    it_interprets %q(1.0  == 1),        [val(true)]
    it_interprets %q(0.1  == 0),        [val(false)]
    it_interprets %q(1.1  == 1),        [val(false)]
    it_interprets %q(1.000001  == 1),   [val(false)]

    it_interprets %q(1.0  == nil),      [val(false)]
    it_interprets %q(1.0  == true),     [val(false)]
    it_interprets %q(1.0  == false),    [val(false)]
    it_interprets %q(1.0  == "hello"),  [val(false)]
    it_interprets %q(1.0  == :hi),      [val(false)]
    it_interprets %q(1.0  == []),       [val(false)]
    it_interprets %q(1.0  == [1, 2]),   [val(false)]
    it_interprets %q(1.0  == {}),       [val(false)]
    it_interprets %q(1.0  == {a: 1}),   [val(false)]
  end

  # Float#!= is the exact inverse of Float#==.
  describe "#!=" do
    it_interprets %q(1.0  != 1.0),      [val(false)]
    it_interprets %q(0.5  != 1.0),      [val(true)]
    it_interprets %q(1.0  != 0.5),      [val(true)]
    it_interprets %q(1.0  != 1.00001),  [val(true)]
    it_interprets %q(0.0  != 0.0),      [val(false)]

    # Comparing to integers succeeds if the float value is integral.
    it_interprets %q(0.0  != 0),        [val(false)]
    it_interprets %q(1.0  != 1),        [val(false)]
    it_interprets %q(0.1  != 0),        [val(true)]
    it_interprets %q(1.1  != 1),        [val(true)]
    it_interprets %q(1.000001  != 1),   [val(true)]

    it_interprets %q(1.0  != nil),      [val(true)]
    it_interprets %q(1.0  != true),     [val(true)]
    it_interprets %q(1.0  != false),    [val(true)]
    it_interprets %q(1.0  != "hello"),  [val(true)]
    it_interprets %q(1.0  != :hi),      [val(true)]
    it_interprets %q(1.0  != []),       [val(true)]
    it_interprets %q(1.0  != [1, 2]),   [val(true)]
    it_interprets %q(1.0  != {}),       [val(true)]
    it_interprets %q(1.0  != {a: 1}),   [val(true)]
  end

  describe "#<" do
    it_interprets %q(1.0 < 1.0),      [val(false)]
    it_interprets %q(0.0 < 1.0),      [val(true)]
    it_interprets %q(1.0 < 0.0),      [val(false)]
    it_interprets %q(0.0 < 0.0),      [val(false)]

    # int
    it_interprets %q(0.0 < 0),        [val(false)]
    it_interprets %q(1.0 < 1),        [val(false)]
    it_interprets %q(0.1 < 0),        [val(false)]
    it_interprets %q(1.1 < 2),        [val(true)]
    it_interprets %q(1.000001 < 2),   [val(true)]

    # it should not compare to non numeric types
    it_does_not_interpret %q(1.0 < nil),      /invalid argument/
    it_does_not_interpret %q(1.0 < true),     /invalid argument/
    it_does_not_interpret %q(1.0 < false),    /invalid argument/
    it_does_not_interpret %q(1.0 < "hello"),  /invalid argument/
    it_does_not_interpret %q(1.0 < :hi),      /invalid argument/
    it_does_not_interpret %q(1.0 < []),       /invalid argument/
    it_does_not_interpret %q(1.0 < [1.0, 2]), /invalid argument/
    it_does_not_interpret %q(1.0 < {}),       /invalid argument/
    it_does_not_interpret %q(1.0 < {a: 1}),   /invalid argument/
  end

  describe "#<=" do
    it_interprets %q(1.0 <= 1.0),      [val(true)]
    it_interprets %q(0.0 <= 1.0),      [val(true)]
    it_interprets %q(1.0 <= 0.0),      [val(false)]
    it_interprets %q(0.0 <= 0.0),      [val(true)]

    # int
    it_interprets %q(0.0 <= 0),        [val(true)]
    it_interprets %q(1.0 <= 1),        [val(true)]
    it_interprets %q(0.1 <= 0),        [val(false)]
    it_interprets %q(1.1 <= 2),        [val(true)]
    it_interprets %q(1.000001 <= 2),   [val(true)]

    # it should not compare to non numeric types
    it_does_not_interpret %q(1.0 <= nil),      /invalid argument/
    it_does_not_interpret %q(1.0 <= true),     /invalid argument/
    it_does_not_interpret %q(1.0 <= false),    /invalid argument/
    it_does_not_interpret %q(1.0 <= "hello"),  /invalid argument/
    it_does_not_interpret %q(1.0 <= :hi),      /invalid argument/
    it_does_not_interpret %q(1.0 <= []),       /invalid argument/
    it_does_not_interpret %q(1.0 <= [1.0, 2]), /invalid argument/
    it_does_not_interpret %q(1.0 <= {}),       /invalid argument/
    it_does_not_interpret %q(1.0 <= {a: 1}),   /invalid argument/
  end
end
