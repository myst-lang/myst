require "stdlib/spec.mt"

describe("Boolean#==") do
  it("returns true for identities") do
    assert(true == true)
    assert(false == false)
  end

  it("returns false for non-identities") do
    refute(true == false)
    refute(false == true)
  end

  it("works in a chained expression") do
    assert(true == true == true)
    refute(true == false == true)
  end

  it("returns false when the operand is not a boolean") do
    refute(true == nil)
    refute(true == 0)
    refute(true == 1)
    refute(true == 1.0)
    refute(true == "hello")
    refute(true == :hi)
    refute(true == [])
    refute(true == [1, 2])
    refute(true == {})
    refute(true == {a: 1})
    refute(false == nil)
    refute(false == 0)
    refute(false == 1)
    refute(false == 1.0)
    refute(false == "hello")
    refute(false == :hi)
    refute(false == [])
    refute(false == [1, 2])
    refute(false == {})
    refute(false == {a: 1})
  end
end


describe("Boolean#!=") do
  it("returns false for identities") do
    refute(true != true)
    refute(false != false)
  end

  it("returns true for non-identities") do
    assert(true != false)
    assert(false != true)
  end

  it("works in a chained expression") do
    assert(true != true != true)
    refute(true != true == true)
    refute(true != false != true)
    assert(true == false != true)
  end

  it("returns true when the operand is not a boolean") do
    assert(true != nil)
    assert(true != 0)
    assert(true != 1)
    assert(true != 1.0)
    assert(true != "hello")
    assert(true != :hi)
    assert(true != [])
    assert(true != [1, 2])
    assert(true != {})
    assert(true != {a: 1})
    assert(false != nil)
    assert(false != 0)
    assert(false != 1)
    assert(false != 1.0)
    assert(false != "hello")
    assert(false != :hi)
    assert(false != [])
    assert(false != [1, 2])
    assert(false != {})
    assert(false != {a: 1})
  end
end


describe("Boolean#to_s") do
  it("returns the word representation of the value") do
    assert(true.to_s == "true")
    assert(false.to_s == "false")
  end

  it("works with expression results") do
    assert((true  && true).to_s   == "true")
    assert((false || false).to_s  == "false")
  end
end
