require "stdlib/spec.mt"

describe("Float#+") do
  it("does simple addition") do
    assert(1.0 + 1.0).equals(2.0)
    assert(2.2 + 2.2).equals(4.4)
  end

  it("does chained addition") do
    assert(1.1 + 1.1 + 1.0).equals(3.2)
    assert(1.2 + 2.2 + 3.2).equals(4.4 + 2.2)
  end

  it("does large addition") do
    assert(100.500 + 500.8).equals(601.300)
    assert(123456.7880 + 987654.310).equals(1_111_111.098)
  end

  it("does nothing with 0") do
    assert(0.0 + 100.0).equals(100.0)
    assert(100.0 + 0.0).equals(100.0)
    assert(10.0 + 0.0 + 10).equals(20.0)
    assert(0.0 + 100.0 + 0.0).equals(100.0)
  end

  it("returns a Float even with an Integer operand") do
    assert(1.0 + 1).equals(2.0)
    assert(12_396_851_265_129.468 + 123).equals(12_396_851_265_252.468)
  end

  it("works with variables as arguments") do
    a = 1.1
    b = 2.1
    assert(a + b).equals(3.2)
  end

  it("does not accept nil as an operand") do
    assert{ 1.0 + nil }.raises
  end

  it("does not accept a boolean as an operand") do
    assert{ 1.0 + true }.raises
  end

  it("does not accept a list as an operand") do
    assert{ 1.0 + [] }.raises
    assert{ 1.0 + [1, 2] }.raises
  end

  it("does not accept a map as an operand") do
    assert{ 1.0 + {} }.raises
    assert{ 1.0 + {a: 1} }.raises
  end

  it("does not accept a string as an operand") do
    assert{ 1.0 + "a" }.raises
  end

  it("does not accept a symbol as an operand") do
    assert{ 1.0 + :hi }.raises
  end
end


describe("Float#-") do
  it("does simple subtraction") do
    assert(1.0 - 1.0).equals(0.0)
    assert(3.0 - 2.0).equals(1.0)
  end

  it("does chained subtraction") do
    assert(1.0 - 1.0 - 1.0).equals(-1.0)
    assert(1.2 + 3.2 - 2.2).equals(4.4 - 2.2)
  end

  it("does large subtraction") do
    assert(100.500 - 500.8).equals(-400.300)
    assert(123456.7880 - 987654.4).equals(-864_197.612)
  end

  it("does nothing with 0") do
    assert(0.0 - 100.0).equals(-100.0)
    assert(100.0 - 0.0).equals( 100.0)
    assert(10.0 - 0.0 - 10.0).equals( 0.0)
    assert(0.0 - 100.0 - 0.0).equals(-100.0)
  end

  it("returns a Float even when given an Integer operand") do
    assert(1.0 - 1).equals(0.0)
    assert(10_000.0 - 0).equals(10_000.00)
  end

  it("works with variables as arguments") do
    a = 5.0
    b = 2.0
    assert(a - b).equals(3.0)
  end

  it("does not accept nil as an operand") do
    assert{ 1.0 - nil }.raises
  end

  it("does not accept a boolean as an operand") do
    assert{ 1.0 - true }.raises
  end

  it("does not accept a list as an operand") do
    assert{ 1.0 - [] }.raises
    assert{ 1.0 - [1, 2] }.raises
  end

  it("does not accept a map as an operand") do
    assert{ 1.0 - {} }.raises
    assert{ 1.0 - {a: 1} }.raises
  end

  it("does not accept a string as an operand") do
    assert{ 1.0 - "a" }.raises
  end

  it("does not accept a symbol as an operand") do
    assert{ 1.0 - :hi }.raises
  end
end


describe("Float#*") do
  it("does simple multiplication") do
    assert(1.0 * 1.0).equals(1.0)
    assert(3.0 * 2.0).equals(6.0)
  end

  it("does chained multiplication") do
    assert(1.2 * 1.2 * 1.2).equals(1.728)
    assert(2.1 * 3.1 * 4.1).equals(26.691)
  end

  it("does large multiplication") do
    assert(100.500 * 500.800).equals(50_330.400)
    assert(123456.7880 * 987654.310).equals(121_932_628_766.95628)
  end

  it("always returns 0 with a 0 operand") do
    assert(0.0 * 100.0).equals(0)
    assert(100.0 * 0.0).equals(0)
    assert(10.0 * 0.0 * 10.0).equals(0)
    assert(0.0 * 100.0 * 0.0).equals(0)
  end

  it("returns a float when given a float operand") do
    assert(1.0 * 1).equals(1.0)
    assert(10_000.5 * 2).equals(20_001.00)
  end

  it("works with variables as arguments") do
    a = 5.0
    b = 2.0
    assert(a * b).equals(10.0)
  end

  it("does not accept nil as an operand") do
    assert{ 1.0 * nil }.raises
  end

  it("does not accept a boolean as an operand") do
    assert{ 1.0 * true }.raises
  end

  it("does not accept a list as an operand") do
    assert{ 1.0 * [] }.raises
    assert{ 1.0 * [1, 2] }.raises
  end

  it("does not accept a map as an operand") do
    assert{ 1.0 * {} }.raises
    assert{ 1.0 * {a: 1} }.raises
  end

  it("does not accept a string as an operand") do
    assert{ 1.0 * "a" }.raises
  end

  it("does not accept a symbol as an operand") do
    assert{ 1.0 * :hi }.raises
  end
end


describe("Float#/") do
  it("does simple division") do
    assert(1.0 / 1.0).equals(1.0)
    assert(6.0 / 4.0).equals(1.5)
  end

  it("does chained division") do
    assert(1.0 / 1.0 / 1.0).equals(1.0)
    assert(2.2 * 3.0 / 3.2).equals(2.0625)
  end

  it("does large divisions") do
    assert(100_000.0 / 10_000.0).equals(10.0)
    assert(625.0 / 25.0).equals(25.0)
  end

  it("does not truncate fractional quotients with Integer divisors") do
    assert(1.0  / 2).equals(0.5)
    assert(10.0 / 3).equals(3.3333333333333335)
    assert(10.0 / 4).equals(2.5)
  end

  it("does not truncate with a Float operand") do
    assert(1.0  / 2.0).equals(0.5)
    assert(10.0 / 3.0).equals(3.3333333333333335)
    assert(10.0 / 2.5).equals(4.0)
  end

  it("returns 0 when 0 is the dividend") do
    assert(0.0 / 10).equals(0.0)
    assert(0.0 / 10.0).equals(0.0)
  end

  it("does not allow division by zero") do
    assert{ 10.0 / 0 }.raises
    assert{ 10.0 / 0.0 }.raises
  end

  it("works with variables as arguments") do
    a = 6.0
    b = 2.0
    assert(a / b).equals(3.0)
  end

  it("does not accept nil as an operand") do
    assert{ 1.0 / nil }.raises
  end

  it("does not accept a boolean as an operand") do
    assert{ 1.0 / true }.raises
  end

  it("does not accept a list as an operand") do
    assert{ 1.0 / [] }.raises
    assert{ 1.0 / [1, 2] }.raises
  end

  it("does not accept a map as an operand") do
    assert{ 1.0 / {} }.raises
    assert{ 1.0 / {a: 1} }.raises
  end

  it("does not accept a string as an operand") do
    assert{ 1.0 / "a" }.raises
  end

  it("does not accept a symbol as an operand") do
    assert{ 1.0 / :hi }.raises
  end
end


describe("Float#%") do
  it("does simple modulation") do
    assert(1.0 % 1.0).equals(0.0)
    assert(6.0 % 2.0).equals(0.0)
  end

  it("does chained modulation") do
    assert(1.0 % 1.0 % 1.0).equals(0.0)
    assert(7.0 % 4.0 % 2.0).equals(1.0)
  end

  it("does large modulation") do
    assert(100_000 % 10_000).equals(0.0)
    assert(625.0 % 21.25).equals(8.75)
  end

  it("returns 0 when 0 is the dividend") do
    assert(0.0 % 10.0).equals(0.0)
  end

  it("does not allow division by zero") do
    assert{ 10.0 % 0 }.raises
    assert{ 10.0 % 0.0 }.raises
  end

  it("works with variables as arguments") do
    a = 6.0
    b = 2.0
    assert(a % b).equals(0.0)
  end

  it("does not accept nil as an operand") do
    assert{ 1.0 % nil }.raises
  end

  it("does not accept a boolean as an operand") do
    assert{ 1.0 % true }.raises
  end

  it("does not accept a list as an operand") do
    assert{ 1.0 % [] }.raises
    assert{ 1.0 % [1.0, 2] }.raises
  end

  it("does not accept a map as an operand") do
    assert{ 1.0 % {} }.raises
    assert{ 1.0 % {a: 1} }.raises
  end

  it("does not accept a string as an operand") do
    assert{ 1.0 % "a" }.raises
  end

  it("does not accept a symbol as an operand") do
    assert{ 1.0 % :hi }.raises
  end
end


describe("Float#to_i") do
  it("returns a new Integer representing the Float") do
    assert(1.0.to_i).equals(1)
    assert(100.0.to_i).equals(100)
  end

  it("truncates decimals to create the Integer") do
    assert(1.4.to_i).equals(1)
    assert(123.456.to_i).equals(123)
  end

  it("does not perform rounding when truncating") do
    assert(1.7.to_i).equals(1)
    assert(10.5.to_i).equals(10)
  end

  it("raises an error if the Float cannot fit into an Integer value") do
    # This number is larger than the maximum storable in a 64-bit integer.
    assert{ 9_223_372_036_854_775_810.0.to_i }.raises
  end
end


describe("Float#round") do
  it("returns a new Integer representing the Float") do
    assert(1.0.round).equals(1)
    assert(100.0.round).equals(100)
  end

  it("rounds to the nearest Integer") do
    assert(1.4.round).equals(1)
    assert(123.789.round).equals(124)
  end

  it("rounds .5 decimals to the higher nearest Integer") do
    assert(1.5.round).equals(2)
    assert(214.5.round).equals(215)
  end

  it("accurately rounds decimals around *.5") do
    assert(100.49999.round).equals(100)
    assert(100.50000.round).equals(101)
    assert(100.50001.round).equals(101)
  end

  it("raises an error if the Float cannot fit into an Integer value") do
    # This number is larger than the maximum storable in a 64-bit integer.
    assert{ 9_223_372_036_854_775_810.0.round }.raises
  end
end


describe("Float#to_s") do
  it("returns the string representation of the number") do
    assert(1.0.to_s).equals("1.0")
    assert(100.0.to_s).equals("100.0")
    assert(123.456.to_s).equals("123.456")
  end

  it("does not include leading 0s") do
    assert(001.0.to_s).equals("1.0")
  end

  it("does not include insignificant trailing 0s") do
    assert(100.200.to_s).equals("100.2")
  end

  it("does not include underscores") do
    assert(1_234_567.0.to_s).equals("1234567.0")
  end
end


describe("Float#==") do
  it("returns true for identities") do
    assert(1.0).equals(1.0)
    assert(0.0).equals(0.0)
    assert(10_000.0).equals(10_000.0)
    assert(0.123).equals(0.123)
  end

  it("returns false for inequalities") do
    assert(0.0).does_not_equal(1.0)
    assert(1.0).does_not_equal(0.0)
    assert(10_000.0).does_not_equal(9_999.99)
  end

  it("returns true for Floats with Integer identities") do
    assert(0.0).equals(0)
    assert(1.0).equals(1)
  end

  it("returns false for Floats with decimal parts") do
    assert(0.1).does_not_equal(0)
    assert(1.0000001).does_not_equal(1)
    assert(0.9999999).does_not_equal(1)
  end

  it("treats 0 and -0 as equal") do
    assert(0.0).equals(-0.0)
  end

  it("returns false when the operand is non-numeric") do
    assert(1.0).does_not_equal(nil)
    assert(1.0).does_not_equal(true)
    assert(1.0).does_not_equal(false)
    assert(1.0).does_not_equal("hello")
    assert(1.0).does_not_equal(:hi)
    assert(1.0).does_not_equal([])
    assert(1.0).does_not_equal([1])
    assert(1.0).does_not_equal([1, 2])
    assert(1.0).does_not_equal({})
    assert(1.0).does_not_equal({a: 1})
  end
end


# Float#!= is the exact inverse of Float#==.
describe("Float#==") do
  it("returns false for identities") do
    assert(1.0 != 1.0).is_false
    assert(0.0 != 0.0).is_false
    assert(10_000.0 != 10_000.0).is_false
    assert(0.123 != 0.123).is_false
  end

  it("returns true for inequalities") do
    assert(0.0 != 1.0).is_true
    assert(1.0 != 0.0).is_true
    assert(10_000.0 != 9_999.99).is_true
  end

  it("returns false for Floats with Integer identities") do
    assert(0.0 != 0).is_false
    assert(1.0 != 1).is_false
  end

  it("returns true for Floats with decimal parts") do
    assert(0.1 != 0).is_true
    assert(1.0000001 != 1).is_true
    assert(0.9999999 != 1).is_true
  end

  it("treats 0 and -0 as equal") do
    assert(0.0 != -0.0).is_false
  end

  it("returns true when the operand is non-numeric") do
    assert(1.0 != nil).is_true
    assert(1.0 != true).is_true
    assert(1.0 != false).is_true
    assert(1.0 != "hello").is_true
    assert(1.0 != :hi).is_true
    assert(1.0 != []).is_true
    assert(1.0 != [1]).is_true
    assert(1.0 != [1, 2]).is_true
    assert(1.0 != {}).is_true
    assert(1.0 != {a: 1}).is_true
  end
end


describe("Float#<") do
  it("returns true for numerically smaller values") do
    assert(0.0  < 1.0).is_true
    assert(1.0  < 1.1).is_true
    assert(-1.0 < 0.0).is_true
    assert(10.0 < 100.0).is_true
  end

  it("returns false for equal values") do
    assert(1.0 < 1.0).is_false
    assert(1.1 < 1.1).is_false
    assert(0.0 < 0.0).is_false
    assert(-10.0 < -10.0).is_false
  end

  it("returns false for numerically larger values") do
    assert(1.0 < 0.0).is_false
    assert(1.1 < 1.0).is_false
    assert(0 < -1).is_false
    assert(0.1 < -1).is_false
  end

  it("returns true for numerically smaller Integers") do
    assert(0.0 < 1).is_true
    assert(1.1 < 2).is_true
  end

  it("returns false for numerically equal Integers") do
    assert(0.0 < 0).is_false
    assert(1.0 < 1).is_false
  end

  it("returns false for numerically larger Integers") do
    assert(0.1 < 0).is_false
    assert(1.0 < 0).is_false
  end

  it("does not accept nil as an operand") do
    assert{ 1.0 < nil }.raises
  end

  it("does not accept a boolean as an operand") do
    assert{ 1.0 < true }.raises
  end

  it("does not accept a list as an operand") do
    assert{ 1.0 < [] }.raises
    assert{ 1.0 < [1, 2] }.raises
  end

  it("does not accept a map as an operand") do
    assert{ 1.0 < {} }.raises
    assert{ 1.0 < {a: 1} }.raises
  end

  it("does not accept a string as an operand") do
    assert{ 1.0 < "a" }.raises
  end

  it("does not accept a symbol as an operand") do
    assert{ 1.0 < :hi }.raises
  end
end


describe("Float#<=") do
  it("returns true for numerically smaller values") do
    assert(0.0  <= 1.0).is_true
    assert(1.0  <= 1.1).is_true
    assert(-1.0 <= 0.0).is_true
    assert(10.0 <= 100.0).is_true
  end

  it("returns true for equal values") do
    assert(1.0 <= 1.0).is_true
    assert(1.1 <= 1.1).is_true
    assert(0.0 <= 0.0).is_true
    assert(-10.0 <= -10.0).is_true
  end

  it("returns false for numerically larger values") do
    assert(1.0 <= 0.0).is_false
    assert(1.1 <= 1.0).is_false
    assert(0 <= -1).is_false
    assert(0.1 <= -1).is_false
  end

  it("returns true for numerically smaller Integers") do
    assert(0.0 <= 1).is_true
    assert(1.1 <= 2).is_true
  end

  it("returns true for numerically equal Integers") do
    assert(0.0 <= 0).is_true
    assert(1.0 <= 1).is_true
  end

  it("returns false for numerically larger Integers") do
    assert(0.1 <= 0).is_false
    assert(1.0 <= 0).is_false
  end

  it("does not accept nil as an operand") do
    assert{ 1.0 <= nil }.raises
  end

  it("does not accept a boolean as an operand") do
    assert{ 1.0 <= true }.raises
  end

  it("does not accept a list as an operand") do
    assert{ 1.0 <= [] }.raises
    assert{ 1.0 <= [1, 2] }.raises
  end

  it("does not accept a map as an operand") do
    assert{ 1.0 <= {} }.raises
    assert{ 1.0 <= {a: 1} }.raises
  end

  it("does not accept a string as an operand") do
    assert{ 1.0 <= "a" }.raises
  end

  it("does not accept a symbol as an operand") do
    assert{ 1.0 <= :hi }.raises
  end
end

describe("Float#>=") do
  it("returns false for numerically smaller values") do
    assert(0.0  >= 1.0).is_false
    assert(1.0  >= 1.1).is_false
    assert(-1.0 >= 0.0).is_false
    assert(10.0 >= 100.0).is_false
  end

  it("returns true for equal values") do
    assert(1.0 >= 1.0).is_true
    assert(1.1 >= 1.1).is_true
    assert(0.0 >= 0.0).is_true
    assert(-10.0 >= -10.0).is_true
  end

  it("returns true for numerically larger values") do
    assert(1.0 >= 0.0).is_true
    assert(1.1 >= 1.0).is_true
    assert(0 >= -1).is_true
    assert(0.1 >= -1).is_true
  end

  it("returns false for numerically smaller Integers") do
    assert(0.0 >= 1).is_false
    assert(1.1 >= 2).is_false
  end

  it("returns true for numerically equal Integers") do
    assert(0.0 >= 0).is_true
    assert(1.0 >= 1).is_true
  end

  it("returns true for numerically larger Integers") do
    assert(0.1 >= 0).is_true
    assert(1.0 >= 0).is_true
  end

  it("does not accept nil as an operand") do
    assert{ 1.0 >= nil }.raises
  end

  it("does not accept a boolean as an operand") do
    assert{ 1.0 >= true }.raises
  end

  it("does not accept a list as an operand") do
    assert{ 1.0 >= [] }.raises
    assert{ 1.0 >= [1, 2] }.raises
  end

  it("does not accept a map as an operand") do
    assert{ 1.0 >= {} }.raises
    assert{ 1.0 >= {a: 1} }.raises
  end

  it("does not accept a string as an operand") do
    assert{ 1.0 >= "a" }.raises
  end

  it("does not accept a symbol as an operand") do
    assert{ 1.0 >= :hi }.raises
  end
end


describe("Float#>") do
  it("returns false for numerically smaller values") do
    assert(0.0  > 1.0).is_false
    assert(1.0  > 1.1).is_false
    assert(-1.0 > 0.0).is_false
    assert(10.0 > 100.0).is_false
  end

  it("returns false for equal values") do
    assert(1.0 > 1.0).is_false
    assert(1.1 > 1.1).is_false
    assert(0.0 > 0.0).is_false
    assert(-10.0 > -10.0).is_false
  end

  it("returns true for numerically larger values") do
    assert(1.0 > 0.0).is_true
    assert(1.1 > 1.0).is_true
    assert(0 > -1).is_true
    assert(0.1 > -1).is_true
  end

  it("returns false for numerically smaller Integers") do
    assert(0.0 > 1).is_false
    assert(1.1 > 2).is_false
  end

  it("returns false for numerically equal Integers") do
    assert(0.0 > 0).is_false
    assert(1.0 > 1).is_false
  end

  it("returns true for numerically larger Integers") do
    assert(0.1 > 0).is_true
    assert(1.0 > 0).is_true
  end

  it("does not accept nil as an operand") do
    assert{ 1.0 > nil }.raises
  end

  it("does not accept a boolean as an operand") do
    assert{ 1.0 > true }.raises
  end

  it("does not accept a list as an operand") do
    assert{ 1.0 > [] }.raises
    assert{ 1.0 > [1, 2] }.raises
  end

  it("does not accept a map as an operand") do
    assert{ 1.0 > {} }.raises
    assert{ 1.0 > {a: 1} }.raises
  end

  it("does not accept a string as an operand") do
    assert{ 1.0 > "a" }.raises
  end

  it("does not accept a symbol as an operand") do
    assert{ 1.0 > :hi }.raises
  end
end
