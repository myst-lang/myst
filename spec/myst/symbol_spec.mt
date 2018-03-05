require "stdlib/spec.mt"


describe("Symbol#==") do
  it("returns true for identities") do
    assert(:hi    == :hi).is_true
    assert(:hello == :hello).is_true
  end

  it("returns false for non-identities") do
    assert(:""      == :hello).is_false
    assert(:hello   == :"").is_false
  end

  it("treats quoting as insignificant") do
    assert(:"hello" == :hello).is_true
    assert(:hello   == :"hello").is_true
  end

  it("treats whitespace as significant") do
    assert(:"hello world" == :helloworld).is_false
  end

  it("returns false when the operand is not a Symbol") do
    assert(:hello  == nil).is_false
    assert(:hello  == true).is_false
    assert(:hello  == false).is_false
    assert(:hello  == 0).is_false
    assert(:hello  == 1).is_false
    assert(:hello  == 0.0).is_false
    assert(:hello  == 1.0).is_false
    assert(:hello  == "hello").is_false
    assert(:hello  == []).is_false
    assert(:hello  == [1, 2]).is_false
    assert(:hello  == {}).is_false
    assert(:hello  == {a: 1}).is_false
  end

  it("is not considered equal with Strings") do
    assert(:hello == "hello").is_false
  end
end


describe("Symbol#!=") do
  it("returns false for identities") do
    assert(:hi    != :hi).is_false
    assert(:hello != :hello).is_false
  end

  it("returns true for non-identities") do
    assert(:""      != :hello).is_true
    assert(:hello   != :"").is_true
  end

  it("treats quoting as insignificant") do
    assert(:"hello" != :hello).is_false
    assert(:hello   != :"hello").is_false
  end

  it("treats whitespace as significant") do
    assert(:"hello world" != :helloworld).is_true
  end

  it("returns true when the operand is not a Symbol") do
    assert(:hello  != nil).is_true
    assert(:hello  != true).is_true
    assert(:hello  != false).is_true
    assert(:hello  != 0).is_true
    assert(:hello  != 1).is_true
    assert(:hello  != 0.0).is_true
    assert(:hello  != 1.0).is_true
    assert(:hello  != "hello").is_true
    assert(:hello  != []).is_true
    assert(:hello  != [1, 2]).is_true
    assert(:hello  != {}).is_true
    assert(:hello  != {a: 1}).is_true
  end

  it("is not considered equal with Strings") do
    assert(:hello != "hello").is_true
  end
end


describe("Symbol#to_s") do
  it("returns a new String with the name of the Symbol") do
    assert(:hello.to_s).equals("hello")
    assert(:"with spaces".to_s).equals("with spaces")
    assert(:"with\nnewlines".to_s).equals("with\nnewlines")
  end
end
