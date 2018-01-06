require "stdlib/spec.mt"

describe("Float#+") do
  it("does simple addition") do
    assert(1.0 + 1.0 == 2.0)
    assert(2.2 + 2.2 == 4.4)
  end

  it("does chained addition") do
    assert(1.1 + 1.1 + 1.0 == 3.2)
    assert(1.2 + 2.2 + 3.2 == 4.4 + 2.2)
  end

  it("does large addition") do
    assert(100.500 + 500.8 == 601.300)
    assert(123456.7880 + 987654.310 == 1_111_111.098)
  end

  it("does nothing with 0") do
    assert(0.0 + 100.0 == 100.0)
    assert(100.0 + 0.0 == 100.0)
    assert(10.0 + 0.0 + 10 ==  20.0)
    assert(0.0 + 100.0 + 0.0 == 100.0)
  end

  it("returns a Float even with an Integer operand") do
    assert(1.0 + 1 == 2.0)
    assert(12_396_851_265_129.468 + 123 == 12_396_851_265_252.468)
  end

  it("works with variables as arguments") do
    a = 1.1
    b = 2.1
    assert(a + b == 3.2)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1.0 + nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1.0 + true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1.0 + [] }
    expect_raises{ 1.0 + [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1.0 + {} }
    expect_raises{ 1.0 + {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1.0 + "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1.0 + :hi }
  end
end


describe("Float#-") do
  it("does simple subtraction") do
    assert(1.0 - 1.0 == 0.0)
    assert(3.0 - 2.0 == 1.0)
  end

  it("does chained subtraction") do
    assert(1.0 - 1.0 - 1.0 == -1.0)
    assert(1.2 + 3.2 - 2.2 == 4.4 - 2.2)
  end

  it("does large subtraction") do
    assert(100.500 - 500.800 == -400.300)
    assert(123456.7880 - 987654.410 == -864_197.622)
  end

  it("does nothing with 0") do
    assert(0.0 - 100.0      == -100.0)
    assert(100.0 - 0.0      ==  100.0)
    assert(10.0 - 0.0 - 10.0  ==    0.0)
    assert(0.0 - 100.0 - 0.0  == -100.0)
  end

  it("returns a Float even when given an Integer operand") do
    assert(1.0 - 1 == 0.0)
    assert(10_000.0 - 0 == 10_000.00)
  end

  it("works with variables as arguments") do
    a = 5.0
    b = 2.0
    assert(a - b == 3.0)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1.0 - nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1.0 - true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1.0 - [] }
    expect_raises{ 1.0 - [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1.0 - {} }
    expect_raises{ 1.0 - {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1.0 - "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1.0 - :hi }
  end
end


describe("Float#*") do
  it("does simple multiplication") do
    assert(1.0 * 1.0 == 1.0)
    assert(3.0 * 2.0 == 6.0)
  end

  it("does chained multiplication") do
    assert(1.2 * 1.2 * 1.2 == 1.728)
    assert(2.1 * 3.1 * 4.1 == 26.691)
  end

  it("does large multiplication") do
    assert(100.500 * 500.800 == 50_330.400)
    assert(123456.7880 * 987654.310 == 121_932_628_766.95628)
  end

  it("always returns 0 with a 0 operand") do
    assert(0.0 * 100.0      == 0)
    assert(100.0 * 0.0      == 0)
    assert(10.0 * 0.0 * 10.0  == 0)
    assert(0.0 * 100.0 * 0.0  == 0)
  end

  it("returns a float when given a float operand") do
    assert(1.0 * 1 == 1.0)
    assert(10_000.5 * 2 == 20_001.00)
  end

  it("works with variables as arguments") do
    a = 5.0
    b = 2.0
    assert(a * b == 10.0)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1.0 * nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1.0 * true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1.0 * [] }
    expect_raises{ 1.0 * [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1.0 * {} }
    expect_raises{ 1.0 * {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1.0 * "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1.0 * :hi }
  end
end


describe("Float#/") do
  it("does simple division") do
    assert(1.0 / 1.0 == 1.0)
    assert(6.0 / 4.0 == 1.5)
  end

  it("does chained division") do
    assert(1.0 / 1.0 / 1.0 == 1.0)
    assert(2.2 * 3.0 / 3.2 == 2.0625)
  end

  it("does large divisions") do
    assert(100_000.0 / 10_000.0 == 10.0)
    assert(625.0 / 25.0 == 25.0)
  end

  it("does not truncate fractional quotients with Integer divisors") do
    assert(1.0  / 2 == 0.5)
    assert(10.0 / 3 == 3.3333333333333335)
    assert(10.0 / 4 == 2.5)
  end

  it("does not truncate with a Float operand") do
    assert(1.0  / 2.0 == 0.5)
    assert(10.0 / 3.0 == 3.3333333333333335)
    assert(10.0 / 2.5 == 4.0)
  end

  it("returns 0 when 0 is the dividend") do
    assert(0.0 / 10 == 0.0)
    assert(0.0 / 10.0 == 0.0)
  end

  it("does not allow division by zero") do
    expect_raises{ 10.0 / 0 }
    expect_raises{ 10.0 / 0.0 }
  end

  it("works with variables as arguments") do
    a = 6.0
    b = 2.0
    assert(a / b == 3.0)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1.0 / nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1.0 / true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1.0 / [] }
    expect_raises{ 1.0 / [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1.0 / {} }
    expect_raises{ 1.0 / {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1.0 / "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1.0 / :hi }
  end
end


describe("Float#%") do
  it("does simple modulation") do
    assert(1.0 % 1.0 == 0.0)
    assert(6.0 % 2.0 == 0.0)
  end

  it("does chained modulation") do
    assert(1.0 % 1.0 % 1.0 == 0.0)
    assert(7.0 % 4.0 % 2.0 == 1.0)
  end

  it("does large modulation") do
    assert(100_000 % 10_000 == 0.0)
    assert(625.0 % 21.25 == 8.75)
  end

  it("returns 0 when 0 is the dividend") do
    assert(0.0 % 10.0 == 0.0)
  end

  it("does not allow division by zero") do
    expect_raises{ 10.0 % 0 }
    expect_raises{ 10.0 % 0.0 }
  end

  it("works with variables as arguments") do
    a = 6.0
    b = 2.0
    assert(a % b == 0.0)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1.0 % nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1.0 % true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1.0 % [] }
    expect_raises{ 1.0 % [1.0, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1.0 % {} }
    expect_raises{ 1.0 % {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1.0 % "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1.0 % :hi }
  end
end


describe("Float#to_s") do
  it("returns the string representation of the number") do
    assert(1.0.to_s   == "1.0")
    assert(100.0.to_s == "100.0")
    assert(123.456.to_s == "123.456")
  end

  it("does not include leading 0s") do
    assert(001.0.to_s == "1.0")
  end

  it("does not include insignificant trailing 0s") do
    assert(100.200.to_s == "100.2")
  end

  it("does not include underscores") do
    assert(1_234_567.0.to_s == "1234567.0")
  end
end


describe("Float#==") do
  it("returns true for identities") do
    assert(1.0 == 1.0)
    assert(0.0 == 0.0)
    assert(10_000.0 == 10_000.0)
    assert(0.123 == 0.123)
  end

  it("returns false for inequalities") do
    refute(0.0 == 1.0)
    refute(1.0 == 0.0)
    refute(10_000.0 == 9_999.99)
  end

  it("returns true for Floats with Integer identities") do
    assert(0.0 == 0)
    assert(1.0 == 1)
  end

  it("returns false for Floats with decimal parts") do
    refute(0.1 == 0)
    refute(1.0000001 == 1)
    refute(0.9999999 == 1)
  end

  it("treats 0 and -0 as equal") do
    assert(0.0 == -0.0)
  end

  it("returns false when the operand is non-numeric") do
    refute(1.0 == nil)
    refute(1.0 == true)
    refute(1.0 == false)
    refute(1.0 == "hello")
    refute(1.0 == :hi)
    refute(1.0 == [])
    refute(1.0 == [1])
    refute(1.0 == [1, 2])
    refute(1.0 == {})
    refute(1.0 == {a: 1})
  end
end


# Float#!= is the exact inverse of Float#==.
describe("Float#==") do
  it("returns false for identities") do
    refute(1.0 != 1.0)
    refute(0.0 != 0.0)
    refute(10_000.0 != 10_000.0)
    refute(0.123 != 0.123)
  end

  it("returns true for inequalities") do
    assert(0.0 != 1.0)
    assert(1.0 != 0.0)
    assert(10_000.0 != 9_999.99)
  end

  it("returns false for Floats with Integer identities") do
    refute(0.0 != 0)
    refute(1.0 != 1)
  end

  it("returns true for Floats with decimal parts") do
    assert(0.1 != 0)
    assert(1.0000001 != 1)
    assert(0.9999999 != 1)
  end

  it("treats 0 and -0 as equal") do
    refute(0.0 != -0.0)
  end

  it("returns true when the operand is non-numeric") do
    assert(1.0 != nil)
    assert(1.0 != true)
    assert(1.0 != false)
    assert(1.0 != "hello")
    assert(1.0 != :hi)
    assert(1.0 != [])
    assert(1.0 != [1])
    assert(1.0 != [1, 2])
    assert(1.0 != {})
    assert(1.0 != {a: 1})
  end
end


describe("Float#<") do
  it("returns true for numerically smaller values") do
    assert(0.0  < 1.0)
    assert(1.0  < 1.1)
    assert(-1.0 < 0.0)
    assert(10.0 < 100.0)
  end

  it("returns false for equal values") do
    refute(1.0 < 1.0)
    refute(1.1 < 1.1)
    refute(0.0 < 0.0)
    refute(-10.0 < -10.0)
  end

  it("returns false for numerically larger values") do
    refute(1.0 < 0.0)
    refute(1.1 < 1.0)
    refute(0 < -1)
    refute(0.1 < -1)
  end

  it("returns true for numerically smaller Integers") do
    assert(0.0 < 1)
    assert(1.1 < 2)
  end

  it("returns false for numerically equal Integers") do
    refute(0.0 < 0)
    refute(1.0 < 1)
  end

  it("returns false for numerically larger Integers") do
    refute(0.1 < 0)
    refute(1.0 < 0)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1.0 < nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1.0 < true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1.0 < [] }
    expect_raises{ 1.0 < [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1.0 < {} }
    expect_raises{ 1.0 < {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1.0 < "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1.0 < :hi }
  end
end


describe("Float#<=") do
  it("returns true for numerically smaller values") do
    assert(0.0  <= 1.0)
    assert(1.0  <= 1.1)
    assert(-1.0 <= 0.0)
    assert(10.0 <= 100.0)
  end

  it("returns true for equal values") do
    assert(1.0 <= 1.0)
    assert(1.1 <= 1.1)
    assert(0.0 <= 0.0)
    assert(-10.0 <= -10.0)
  end

  it("returns false for numerically larger values") do
    refute(1.0 <= 0.0)
    refute(1.1 <= 1.0)
    refute(0 <= -1)
    refute(0.1 <= -1)
  end

  it("returns true for numerically smaller Integers") do
    assert(0.0 <= 1)
    assert(1.1 <= 2)
  end

  it("returns true for numerically equal Integers") do
    assert(0.0 <= 0)
    assert(1.0 <= 1)
  end

  it("returns false for numerically larger Integers") do
    refute(0.1 <= 0)
    refute(1.0 <= 0)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1.0 <= nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1.0 <= true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1.0 <= [] }
    expect_raises{ 1.0 <= [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1.0 <= {} }
    expect_raises{ 1.0 <= {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1.0 <= "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1.0 <= :hi }
  end
end

describe("Float#>=") do
  it("returns false for numerically smaller values") do
    refute(0.0  >= 1.0)
    refute(1.0  >= 1.1)
    refute(-1.0 >= 0.0)
    refute(10.0 >= 100.0)
  end

  it("returns true for equal values") do
    assert(1.0 >= 1.0)
    assert(1.1 >= 1.1)
    assert(0.0 >= 0.0)
    assert(-10.0 >= -10.0)
  end

  it("returns true for numerically larger values") do
    assert(1.0 >= 0.0)
    assert(1.1 >= 1.0)
    assert(0 >= -1)
    assert(0.1 >= -1)
  end

  it("returns false for numerically smaller Integers") do
    refute(0.0 >= 1)
    refute(1.1 >= 2)
  end

  it("returns true for numerically equal Integers") do
    assert(0.0 >= 0)
    assert(1.0 >= 1)
  end

  it("returns true for numerically larger Integers") do
    assert(0.1 >= 0)
    assert(1.0 >= 0)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1.0 >= nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1.0 >= true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1.0 >= [] }
    expect_raises{ 1.0 >= [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1.0 >= {} }
    expect_raises{ 1.0 >= {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1.0 >= "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1.0 >= :hi }
  end
end


describe("Float#>") do
  it("returns false for numerically smaller values") do
    refute(0.0  > 1.0)
    refute(1.0  > 1.1)
    refute(-1.0 > 0.0)
    refute(10.0 > 100.0)
  end

  it("returns false for equal values") do
    refute(1.0 > 1.0)
    refute(1.1 > 1.1)
    refute(0.0 > 0.0)
    refute(-10.0 > -10.0)
  end

  it("returns true for numerically larger values") do
    assert(1.0 > 0.0)
    assert(1.1 > 1.0)
    assert(0 > -1)
    assert(0.1 > -1)
  end

  it("returns false for numerically smaller Integers") do
    refute(0.0 > 1)
    refute(1.1 > 2)
  end

  it("returns false for numerically equal Integers") do
    refute(0.0 > 0)
    refute(1.0 > 1)
  end

  it("returns true for numerically larger Integers") do
    assert(0.1 > 0)
    assert(1.0 > 0)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1.0 > nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1.0 > true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1.0 > [] }
    expect_raises{ 1.0 > [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1.0 > {} }
    expect_raises{ 1.0 > {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1.0 > "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1.0 > :hi }
  end
end
