require "stdlib/spec.mt"


describe("Nil#==") do
  it("returns true only if the operand is nil") do
    assert(nil == nil)
  end

  it("returns false if the operand is not exactly nil") do
    refute(nil  == true)
    refute(nil  == false)
    refute(nil  == 0)
    refute(nil  == 1)
    refute(nil  == 0.0)
    refute(nil  == 1.0)
    refute(nil  == "hello")
    refute(nil  == :hi)
    refute(nil  == [])
    refute(nil  == [1, 2])
    refute(nil  == {})
    refute(nil  == {a: 1})
  end
end


describe("Nil#!=") do
  it("returns false only if the operand is nil") do
    refute(nil != nil)
  end

  it("returns true if the operand is not exactly nil") do
    assert(nil  != true)
    assert(nil  != false)
    assert(nil  != 0)
    assert(nil  != 1)
    assert(nil  != 0.0)
    assert(nil  != 1.0)
    assert(nil  != "hello")
    assert(nil  != :hi)
    assert(nil  != [])
    assert(nil  != [1, 2])
    assert(nil  != {})
    assert(nil  != {a: 1})
  end
end


describe("Nil#to_s") do
  it("returns an empty string") do
    assert(nil.to_s == "")
  end
end
