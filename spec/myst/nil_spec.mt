require "stdlib/spec.mt"


describe("Nil#==") do
  it("returns true only if the operand is nil") do
    assert(nil == nil).is_true
  end

  it("returns false if the operand is not exactly nil") do
    assert(nil  == true).is_false
    assert(nil  == false).is_false
    assert(nil  == 0).is_false
    assert(nil  == 1).is_false
    assert(nil  == 0.0).is_false
    assert(nil  == 1.0).is_false
    assert(nil  == "hello").is_false
    assert(nil  == :hi).is_false
    assert(nil  == []).is_false
    assert(nil  == [1, 2]).is_false
    assert(nil  == {}).is_false
    assert(nil  == {a: 1}).is_false
  end
end


describe("Nil#!=") do
  it("returns false only if the operand is nil") do
    assert(nil != nil).is_false
  end

  it("returns true if the operand is not exactly nil") do
    assert(nil  != true).is_true
    assert(nil  != false).is_true
    assert(nil  != 0).is_true
    assert(nil  != 1).is_true
    assert(nil  != 0.0).is_true
    assert(nil  != 1.0).is_true
    assert(nil  != "hello").is_true
    assert(nil  != :hi).is_true
    assert(nil  != []).is_true
    assert(nil  != [1, 2]).is_true
    assert(nil  != {}).is_true
    assert(nil  != {a: 1}).is_true
  end
end


describe("Nil#to_s") do
  it("returns an empty string") do
    assert(nil.to_s).equals("")
  end
end
