require "stdlib/spec.mt"

describe("Boolean#==") do
  it("returns true for identities") do
    assert(true == true).is_true
    assert(false == false).is_true
  end

  it("returns false for non-identities") do
    assert(true == false).is_false
    assert(false == true).is_false
  end

  it("works in a chained expression") do
    assert(true == true == true).is_true
    assert(true == false == true).is_false
  end

  it("returns false when the operand is not a boolean") do
    assert(true == nil      ).is_false
    assert(true == 0        ).is_false
    assert(true == 1        ).is_false
    assert(true == 1.0      ).is_false
    assert(true == "hello"  ).is_false
    assert(true == :hi      ).is_false
    assert(true == []       ).is_false
    assert(true == [1, 2]   ).is_false
    assert(true == {}       ).is_false
    assert(true == {a: 1}   ).is_false
    assert(false == nil     ).is_false
    assert(false == 0       ).is_false
    assert(false == 1       ).is_false
    assert(false == 1.0     ).is_false
    assert(false == "hello" ).is_false
    assert(false == :hi     ).is_false
    assert(false == []      ).is_false
    assert(false == [1, 2]  ).is_false
    assert(false == {}      ).is_false
    assert(false == {a: 1}  ).is_false
  end
end


describe("Boolean#!=") do
  it("returns false for identities") do
    assert(true != true).is_false
    assert(false != false).is_false
  end

  it("returns true for non-identities") do
    assert(true != false).is_true
    assert(false != true).is_true
  end

  it("works in a chained expression") do
    assert(true != true != true).is_true
    assert(true != true == true).is_false
    assert(true != false != true).is_false
    assert(true == false != true).is_true
  end

  it("returns true when the operand is not a boolean") do
    assert(true != nil      ).is_true
    assert(true != 0        ).is_true
    assert(true != 1        ).is_true
    assert(true != 1.0      ).is_true
    assert(true != "hello"  ).is_true
    assert(true != :hi      ).is_true
    assert(true != []       ).is_true
    assert(true != [1, 2]   ).is_true
    assert(true != {}       ).is_true
    assert(true != {a: 1}   ).is_true
    assert(false != nil     ).is_true
    assert(false != 0       ).is_true
    assert(false != 1       ).is_true
    assert(false != 1.0     ).is_true
    assert(false != "hello" ).is_true
    assert(false != :hi     ).is_true
    assert(false != []      ).is_true
    assert(false != [1, 2]  ).is_true
    assert(false != {}      ).is_true
    assert(false != {a: 1}  ).is_true
  end
end


describe("Boolean#to_s") do
  it("returns the word representation of the value") do
    assert(true.to_s).equals("true")
    assert(false.to_s).equals("false")
  end

  it("works with expression results") do
    assert((true  && true).to_s).equals("true")
    assert((false || false).to_s).equals("false")
  end
end
