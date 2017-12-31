require "stdlib/spec.mt"


describe("String#==") do
  it("only returns true if the content of the strings is equivalent") do
    assert(""       == "")
    assert("hello"  == "hello")
  end

  it("returns false if the content is not equivalent") do
    refute(""       == "hello")
    refute("hello"  == "")
  end

  it("treats whitespace as significant") do
    refute("\0" == "")
    refute("  " == "")
    refute("\t" == "  ")
    refute("hello world"  == "helloworld")
  end

  it("is always false for non-string operands") do
    refute("hello"  == nil)
    refute("hello"  == true)
    refute("hello"  == false)
    refute("hello"  == 0)
    refute("hello"  == 1)
    refute("hello"  == 0.0)
    refute("hello"  == 1.0)
    refute("hello"  == :hi)
    refute("hello"  == [])
    refute("hello"  == [1, 2])
    refute("hello"  == {})
    refute("hello"  == {a: 1})
  end

  it("does not equate with symbols") do
    refute("hello"  == :hello)
  end
end


describe("String#!=") do
  it("only returns false if the content of the strings is equivalent") do
    refute(""       != "")
    refute("hello"  != "hello")
  end

  it("returns true if the content is not equivalent") do
    assert(""       != "hello")
    assert("hello"  != "")
  end

  it("treats whitespace as significant") do
    assert("\0" != "")
    assert("  " != "")
    assert("\t" != "  ")
    assert("hello world"  != "helloworld")
  end

  it("is always true for non-string operands") do
    assert("hello"  != nil)
    assert("hello"  != true)
    assert("hello"  != false)
    assert("hello"  != 0)
    assert("hello"  != 1)
    assert("hello"  != 0.0)
    assert("hello"  != 1.0)
    assert("hello"  != :hi)
    assert("hello"  != [])
    assert("hello"  != [1, 2])
    assert("hello"  != {})
    assert("hello"  != {a: 1})
  end

  it("does not equate with symbols") do
    assert("hello"  != :hello)
  end
end


describe("String#+") do
  it("returns a new string with the contents of both operands") do
    assert("hello" + "world" == "helloworld")
    assert("hello\n" + "world" == "hello\nworld")
    assert("" + "world" == "world")
  end

  it("does not accept non-string arguments") do
    expect_raises{ "abc" + 123 }
    expect_raises{ "abc" + 1.0 }
    expect_raises{ "abc" + nil }
    expect_raises{ "abc" + false }
    expect_raises{ "abc" + :hi }
    expect_raises{ "abc" + [] }
    expect_raises{ "abc" + {} }
  end

  it("works with other values when `to_s` is called on them") do
    assert("abc" + 123.to_s == "abc123")
  end

  it("does not modify the receiving string") do
    str = "hello"
    str2 = str + "world"

    assert(str == "hello")
  end
end


describe("String#*") do
  it("returns a new string with the content repeated n times") do
    assert("hi" * 3 == "hihihi")
  end

  it("only accepts an Integer argument") do
    expect_raises{ "abc" * 1.0 }
    expect_raises{ "abc" * nil }
    expect_raises{ "abc" * false }
    expect_raises{ "abc" * "hi" }
    expect_raises{ "abc" * :hi }
    expect_raises{ "abc" * [] }
    expect_raises{ "abc" * {} }
  end
end


describe("String#empty?") do
  it("with an empty string") do
    assert("".empty?)
  end

  it("with a non-empty string") do
    assert("test".empty? == false)
  end
end


describe("String#to_s") do
  it("returns itself") do
    assert("".to_s == "")
    assert("\n".to_s == "\n")
    assert("hello".to_s == "hello")
    assert("\tone\ttwo".to_s == "\tone\ttwo")
  end
end
