require "stdlib/spec.mt"

describe("Integer#+") do
  it("does simple addition") do
    assert(1 + 1 == 2)
    assert(2 + 2 == 4)
  end

  it("does chained addition") do
    assert(1 + 1 + 1 == 3)
    assert(1 + 2 + 3 == 4 + 2)
  end

  it("does large addition") do
    assert(2_000 + 4_567 == 6_567)
    assert(10_000 + 100_000 == 110_000)
    assert(1234567890 + 987654310 == 2_222_222_200)
  end

  it("wraps around max int to negatives") do
    assert(9_223_372_036_854_775_807 + 1 == -9_223_372_036_854_775_807-1)
  end

  it("does nothing with 0") do
    assert(0 + 100 == 100)
    assert(100 + 0 == 100)
    assert(10 + 0 + 10 ==  20)
    assert(0 + 100 + 0 == 100)
  end

  it("returns a float when given a float operand") do
    assert(1 + 1.0 == 2.0)
    assert(123 + 12_396_851_265_129.468 == 12_396_851_265_252.468)
  end

  it("works with variables as arguments") do
    a = 1
    b = 2
    assert(a + b == 3)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1 + nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1 + true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1 + [] }
    expect_raises{ 1 + [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1 + {} }
    expect_raises{ 1 + {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1 + "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1 + :hi }
  end
end


describe("Integer#-") do
  it("does simple subtraction") do
    assert(1 - 1 == 0)
    assert(3 - 2 == 1)
  end

  it("does chained subtraction") do
    assert(1 - 1 - 1 == -1)
    assert(1 + 3 - 2 == 4 - 2)
  end

  it("does large subtraction") do
    assert(4_567  - 2_000   == 2_567)
    assert(10_000 - 100_000 == -90_000)
    assert(1234567890 - 987654310 == 246_913_580)
  end

  it("wraps around min int to positives") do
    assert(-9_223_372_036_854_775_807 - 2 == 9_223_372_036_854_775_807)
  end

  it("does nothing with 0") do
    assert(0 - 100      == -100)
    assert(100 - 0      ==  100)
    assert(10 - 0 - 10  ==    0)
    assert(0 - 100 - 0  == -100)
  end

  it("returns a float when given a float operand") do
    assert(1 - 1.0 == 0.0)
    assert(10_000 - 0.50 == 9_999.50)
  end

  it("works with variables as arguments") do
    a = 5
    b = 2
    assert(a - b == 3)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1 - nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1 - true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1 - [] }
    expect_raises{ 1 - [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1 - {} }
    expect_raises{ 1 - {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1 - "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1 - :hi }
  end
end


describe("Integer#*") do
  it("does simple multiplication") do
    assert(1 * 1 == 1)
    assert(3 * 2 == 6)
  end

  it("does chained multiplication") do
    assert(1 * 1 * 1 == 1)
    assert(2 * 3 * 4 == 24)
  end

  it("does large multiplications") do
    assert(10_000 * 100_000 == 1_000_000_000)
    assert(1234567 * 987654 == 1_219_325_035_818)
  end

  it("truncates large products") do
    assert(9_223_372_036_854_775_807 * 3 == 9_223_372_036_854_775_805)
  end

  it("always returns 0 with a 0 operand") do
    assert(0 * 100      == 0)
    assert(100 * 0      == 0)
    assert(10 * 0 * 10  == 0)
    assert(0 * 100 * 0  == 0)
  end

  it("returns a float when given a float operand") do
    assert(1 * 1.0 == 1.0)
    assert(10_000 * 0.50 == 5_000.00)
  end

  it("works with variables as arguments") do
    a = 5
    b = 2
    assert(a * b == 10)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1 * nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1 * true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1 * [] }
    expect_raises{ 1 * [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1 * {} }
    expect_raises{ 1 * {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1 * "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1 * :hi }
  end
end


describe("Integer#/") do
  it("does simple division") do
    assert(1 / 1 == 1)
    assert(6 / 2 == 3)
  end

  it("does chained division") do
    assert(1 / 1 / 1 == 1)
    assert(2 * 3 / 3 == 2)
  end

  it("does large divisions") do
    assert(100_000 / 10_000 == 10)
    assert(625 / 25 == 25)
  end

  it("truncates fractional quotients to Integers") do
    assert(1  / 2 == 0)
    assert(10 / 3 == 3)
    assert(10 / 4 == 2)
  end

  it("does not truncate with a Float operand") do
    assert(1  / 2.0 == 0.5)
    assert(10 / 3.0 == 3.3333333333333335)
    assert(10 / 2.5 == 4.0)
  end

  it("returns 0 when 0 is the dividend") do
    assert(0 / 10 == 0)
  end

  it("does not allow division by zero") do
    expect_raises{ 10 / 0 }
  end

  it("works with variables as arguments") do
    a = 6
    b = 2
    assert(a / b == 3)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1 / nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1 / true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1 / [] }
    expect_raises{ 1 / [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1 / {} }
    expect_raises{ 1 / {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1 / "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1 / :hi }
  end
end


describe("Integer#%") do
  it("does simple modulation") do
    assert(1 % 1 == 0)
    assert(6 % 2 == 0)
  end

  it("does chained modulation") do
    assert(1 % 1 % 1 == 0)
    assert(7 % 4 % 2 == 1)
  end

  it("does large modulation") do
    assert(100_000 % 10_000 == 0)
    assert(625 % 21 == 16)
  end

  it("always returns a Float when given a Float operand") do
    assert(625 % 21.25  == 8.75)
    assert(10 % 3.4     == 3.2)
  end

  it("returns 0 when 0 is the dividend") do
    assert(0 % 10 == 0)
  end

  it("does not allow division by zero") do
    expect_raises{ 10 % 0 }
  end

  it("works with variables as arguments") do
    a = 6
    b = 2
    assert(a % b == 0)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1 % nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1 % true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1 % [] }
    expect_raises{ 1 % [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1 % {} }
    expect_raises{ 1 % {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1 % "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1 % :hi }
  end
end


describe("Integer#times") do
  it("calls a block as many times as integer value") do
    calls = 0
    3.times { calls += 1 }
    assert(calls == 3)
  end

  it("returns the integer") do
    assert(2.times { } == 2)
  end
end


describe("Integer#to_s") do
  it("returns the string representation of the integer") do
    assert(1.to_s   == "1")
    assert(100.to_s == "100")
  end

  it("does not include leading 0s") do
    assert(001.to_s == "1")
  end

  it("does not include underscores") do
    assert(1_234_567.to_s == "1234567")
  end
end


describe("Integer#==") do
  it("returns true for identities") do
    assert(1 == 1)
    assert(0 == 0)
    assert(10_000 == 10_000)
  end

  it("returns false for inequalities") do
    refute(0 == 1)
    refute(1 == 0)
    refute(10_000 == 9_999)
  end

  it("returns true for Floats with Integer identities") do
    assert(0 == 0.0)
    assert(1 == 1.0)
  end

  it("returns false for Floats with decimal parts") do
    refute(0 == 0.1)
    refute(1 == 1.0000001)
    refute(1 == 0.999999)
  end

  it("treats 0 and -0 as equal") do
    assert(0 == -0)
  end

  it("returns false when the operand is non-numeric") do
    refute(1 == nil)
    refute(1 == true)
    refute(1 == false)
    refute(1 == "hello")
    refute(1 == :hi)
    refute(1 == [])
    refute(1 == [1])
    refute(1 == [1, 2])
    refute(1 == {})
    refute(1 == {a: 1})
  end
end


# Integer#!= is the exact inverse of Integer#==.
describe("Integer#!=") do
  it("returns false for identities") do
    refute(1 != 1)
    refute(0 != 0)
    refute(10_000 != 10_000)
  end

  it("returns true for inequalities") do
    assert(0 != 1)
    assert(1 != 0)
    assert(10_000 != 9_999)
  end

  it("returns false for Floats with Integer identities") do
    refute(0 != 0.0)
    refute(1 != 1.0)
  end

  it("returns true for Floats with decimal parts") do
    assert(0 != 0.1)
    assert(1 != 1.0000001)
    assert(1 != 0.999999)
  end

  it("treats 0 and -0 as equal") do
    refute(0 != -0)
  end

  it("returns true when the operand is non-numeric") do
    assert(1 != nil)
    assert(1 != true)
    assert(1 != false)
    assert(1 != "hello")
    assert(1 != :hi)
    assert(1 != [])
    assert(1 != [1])
    assert(1 != [1, 2])
    assert(1 != {})
    assert(1 != {a: 1})
  end
end


describe("Integer#<") do
  it("returns true for numerically smaller values") do
    assert(0  < 1)
    assert(-1 < 0)
    assert(10 < 100)
  end

  it("returns false for equal values") do
    refute(1 < 1)
    refute(0 < 0)
    refute(-10 < -10)
  end

  it("returns false for numerically larger values") do
    refute(1 < 0)
    refute(0 < -1)
  end

  it("returns true for numerically smaller Floats") do
    assert(0 < 0.1)
    assert(1 < 1.1)
  end

  it("returns false for numerically equal Floats") do
    refute(0 < 0.0)
    refute(1 < 1.0)
  end

  it("returns false for numerically larger Floats") do
    refute(0 < -0.1)
    refute(1 <  0.9)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1 < nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1 < true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1 < [] }
    expect_raises{ 1 < [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1 < {} }
    expect_raises{ 1 < {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1 < "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1 < :hi }
  end
end


describe("Integer#<=") do
  it("returns true for numerically smaller values") do
    assert(0  <= 1)
    assert(-1 <= 0)
    assert(10 <= 100)
  end

  it("returns true for equal values") do
    assert(1 <= 1)
    assert(0 <= 0)
    assert(-10 <= -10)
  end

  it("returns false for numerically larger values") do
    refute(1 <= 0)
    refute(0 <= -1)
  end

  it("returns true for numerically smaller Floats") do
    assert(0 <= 0.1)
    assert(1 <= 1.1)
  end

  it("returns true for numerically equal Floats") do
    assert(0 <= 0.0)
    assert(1 <= 1.0)
  end

  it("returns false for numerically larger Floats") do
    refute(0 <= -0.1)
    refute(1 <=  0.9)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1 <= nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1 <= true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1 <= [] }
    expect_raises{ 1 <= [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1 <= {} }
    expect_raises{ 1 <= {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1 <= "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1 <= :hi }
  end
end


describe("Integer#>=") do
  it("returns false for numerically smaller values") do
    refute(0  >= 1)
    refute(-1 >= 0)
    refute(10 >= 100)
  end

  it("returns true for equal values") do
    assert(1 >= 1)
    assert(0 >= 0)
    assert(-10 >= -10)
  end

  it("returns true for numerically larger values") do
    assert(1 >= 0)
    assert(0 >= -1)
  end

  it("returns false for numerically smaller Floats") do
    refute(0 >= 0.1)
    refute(1 >= 1.1)
  end

  it("returns true for numerically equal Floats") do
    assert(0 >= 0.0)
    assert(1 >= 1.0)
  end

  it("returns true for numerically larger Floats") do
    assert(0 >= -0.1)
    assert(1 >=  0.9)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1 >= nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1 >= true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1 >= [] }
    expect_raises{ 1 >= [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1 >= {} }
    expect_raises{ 1 >= {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1 >= "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1 >= :hi }
  end
end


describe("Integer#>") do
  it("returns false for numerically smaller values") do
    refute(0  > 1)
    refute(-1 > 0)
    refute(10 > 100)
  end

  it("returns false for equal values") do
    refute(1 > 1)
    refute(0 > 0)
    refute(-10 > -10)
  end

  it("returns true for numerically larger values") do
    assert(1 > 0)
    assert(0 > -1)
  end

  it("returns false for numerically smaller Floats") do
    refute(0 > 0.1)
    refute(1 > 1.1)
  end

  it("returns false for numerically equal Floats") do
    refute(0 > 0.0)
    refute(1 > 1.0)
  end

  it("returns true for numerically larger Floats") do
    assert(0 > -0.1)
    assert(1 >  0.9)
  end

  it("does not accept nil as an operand") do
    expect_raises{ 1 > nil }
  end

  it("does not accept a boolean as an operand") do
    expect_raises{ 1 > true }
  end

  it("does not accept a list as an operand") do
    expect_raises{ 1 > [] }
    expect_raises{ 1 > [1, 2] }
  end

  it("does not accept a map as an operand") do
    expect_raises{ 1 > {} }
    expect_raises{ 1 > {a: 1} }
  end

  it("does not accept a string as an operand") do
    expect_raises{ 1 > "a" }
  end

  it("does not accept a symbol as an operand") do
    expect_raises{ 1 > :hi }
  end
end
