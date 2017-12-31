require "stdlib/spec.mt"


describe("Symbol#==") do
  it("returns true for identities") do
    assert(:hi    == :hi)
    assert(:hello == :hello)
  end

  it("returns false for non-identities") do
    refute(:""      == :hello)
    refute(:hello   == :"")
  end

  it("treats quoting as insignificant") do
    assert(:"hello" == :hello)
    assert(:hello   == :"hello")
  end

  it("treats whitespace as significant") do
    refute(:"hello world" == :helloworld)
  end

  it("returns false when the operand is not a Symbol") do
    refute(:hello  == nil)
    refute(:hello  == true)
    refute(:hello  == false)
    refute(:hello  == 0)
    refute(:hello  == 1)
    refute(:hello  == 0.0)
    refute(:hello  == 1.0)
    refute(:hello  == "hello")
    refute(:hello  == [])
    refute(:hello  == [1, 2])
    refute(:hello  == {})
    refute(:hello  == {a: 1})
  end

  it("is not considered equal with Strings") do
    refute(:hello == "hello")
  end
end


describe("Symbol#!=") do
  it("returns false for identities") do
    refute(:hi    != :hi)
    refute(:hello != :hello)
  end

  it("returns true for non-identities") do
    assert(:""      != :hello)
    assert(:hello   != :"")
  end

  it("treats quoting as insignificant") do
    refute(:"hello" != :hello)
    refute(:hello   != :"hello")
  end

  it("treats whitespace as significant") do
    assert(:"hello world" != :helloworld)
  end

  it("returns true when the operand is not a Symbol") do
    assert(:hello  != nil)
    assert(:hello  != true)
    assert(:hello  != false)
    assert(:hello  != 0)
    assert(:hello  != 1)
    assert(:hello  != 0.0)
    assert(:hello  != 1.0)
    assert(:hello  != "hello")
    assert(:hello  != [])
    assert(:hello  != [1, 2])
    assert(:hello  != {})
    assert(:hello  != {a: 1})
  end

  it("is not considered equal with Strings") do
    assert(:hello != "hello")
  end
end


describe("Symbol#to_s") do
  it("returns a new String with the name of the Symbol") do
    assert(:hello.to_s == "hello")
    assert(:"with spaces".to_s == "with spaces")
    assert(:"with\nnewlines".to_s == "with\nnewlines")
  end
end
