require "stdlib/spec.mt"


describe("String#==") do
  it("only returns true if the content of the strings is equivalent") do
    assert(""       == "").is_true
    assert("hello"  == "hello").is_true
  end

  it("returns false if the content is not equivalent") do
    assert(""       == "hello").is_false
    assert("hello"  == "").is_false
  end

  it("treats whitespace as significant") do
    assert("\0" == "").is_false
    assert("  " == "").is_false
    assert("\t" == "  ").is_false
    assert("hello world"  == "helloworld").is_false
  end

  it("is always false for non-string operands") do
    assert("hello"  == nil).is_false
    assert("hello"  == true).is_false
    assert("hello"  == false).is_false
    assert("hello"  == 0).is_false
    assert("hello"  == 1).is_false
    assert("hello"  == 0.0).is_false
    assert("hello"  == 1.0).is_false
    assert("hello"  == :hi).is_false
    assert("hello"  == []).is_false
    assert("hello"  == [1, 2]).is_false
    assert("hello"  == {}).is_false
    assert("hello"  == {a: 1}).is_false
  end

  it("does not equate with symbols") do
    assert("hello"  == :hello).is_false
  end
end


describe("String#!=") do
  it("only returns false if the content of the strings is equivalent") do
    assert(""       != "").is_false
    assert("hello"  != "hello").is_false
  end

  it("returns true if the content is not equivalent") do
    assert(""       != "hello").is_true
    assert("hello"  != "").is_true
  end

  it("treats whitespace as significant") do
    assert("\0" != "").is_true
    assert("  " != "").is_true
    assert("\t" != "  ").is_true
    assert("hello world"  != "helloworld").is_true
  end

  it("is always true for non-string operands") do
    assert("hello"  != nil).is_true
    assert("hello"  != true).is_true
    assert("hello"  != false).is_true
    assert("hello"  != 0).is_true
    assert("hello"  != 1).is_true
    assert("hello"  != 0.0).is_true
    assert("hello"  != 1.0).is_true
    assert("hello"  != :hi).is_true
    assert("hello"  != []).is_true
    assert("hello"  != [1, 2]).is_true
    assert("hello"  != {}).is_true
    assert("hello"  != {a: 1}).is_true
  end

  it("does not equate with symbols") do
    assert("hello"  != :hello).is_true
  end
end


describe("String#+") do
  it("returns a new string with the contents of both operands") do
    assert("hello" + "world").equals("helloworld")
    assert("hello\n" + "world").equals("hello\nworld")
    assert("" + "world").equals("world")
  end

  it("does not accept non-string arguments") do
    assert{ "abc" + 123 }.raises
    assert{ "abc" + 1.0 }.raises
    assert{ "abc" + nil }.raises
    assert{ "abc" + false }.raises
    assert{ "abc" + :hi }.raises
    assert{ "abc" + [] }.raises
    assert{ "abc" + {} }.raises
  end

  it("works with other values when `to_s` is called on them") do
    assert("abc" + 123.to_s).equals("abc123")
  end

  it("does not modify the receiving string") do
    str = "hello"
    str2 = str + "world"

    assert(str).equals("hello")
  end
end


describe("String#*") do
  it("returns a new string with the content repeated n times") do
    assert("hi" * 3).equals("hihihi")
  end

  it("only accepts an Integer argument") do
    assert{ "abc" * 1.0 }.raises
    assert{ "abc" * nil }.raises
    assert{ "abc" * false }.raises
    assert{ "abc" * "hi" }.raises
    assert{ "abc" * :hi }.raises
    assert{ "abc" * [] }.raises
    assert{ "abc" * {} }.raises
  end
end


describe("String#empty?") do
  it("with an empty string") do
    assert("".empty?).is_true
  end

  it("with a non-empty string") do
    assert("test".empty?).is_false
  end
end


describe("String#to_s") do
  it("returns itself") do
    assert("".to_s).equals("")
    assert("\n".to_s).equals("\n")
    assert("hello".to_s).equals("hello")
    assert("\tone\ttwo".to_s).equals("\tone\ttwo")
  end
end

describe("String#chars") do
  it("Returns a List with chars in a string") do
    assert("abc".chars).equals(["a", "b", "c"])
    assert("yay".chars).equals(["y", "a", "y"])
  end
end

describe("String#downcase") do
  it("returns a lowercased version of itself") do
    assert("HELLO".downcase).equals("hello")
  end

  it("downcases all characters when the original string is mixed case") do
    assert("hElLo".downcase).equals("hello")
  end

  it("returns the same string when all characters are already downcased") do
    assert("hello".downcase).equals("hello")
  end

  it("returns an empty string when the original string is empty") do
    assert("".downcase).equals("")
  end

  it("preserves white space in string") do
    assert("Bobby Fischer".downcase).equals("bobby fischer")
  end

  it("preserves special characters in the string") do
    assert("\n\t∊ℤ(0, 300]^&*<>#$%\r\n".downcase).equals("\n\t∊ℤ(0, 300]^&*<>#$%\r\n")
  end
end


describe("String#upcase") do
  it("returns a uppercased version of itself") do
    assert("hello".upcase).equals("HELLO")
  end

  it("upcases all characters when the original string is mixed case") do
    assert("hElLO".upcase).equals("HELLO")
  end

  it("returns the same string when all characters are already upcased") do
    assert("hello".upcase).equals("HELLO")
  end

  it("returns an empty string when the original string is empty") do
    assert("".upcase).equals("")
  end

  it("preserves white space in string") do
    assert("Garry Kasparov".upcase).equals("GARRY KASPAROV")
  end

  it("preserves special characters in the string") do
    assert("\n\t∊ℤ(0, 300]^&*<>#$%\r\n".upcase).equals("\n\t∊ℤ(0, 300]^&*<>#$%\r\n")
  end
end

describe("String#chomp") do
  it("Returns self with a newline at the end removed when no argument is provided") do
    assert("Bob likes to fish\n".chomp).equals("Bob likes to fish")
  end

  it("Returns self with specified string removed from the end") do
    assert("Fish does not like to be fish".chomp(" fish")).equals("Fish does not like to be")
  end
end

describe("String#strip") do
  it("Returns a new string with all leading and trailing whitespace removed") do
    assert("   Hello \t".strip).equals("Hello")

    # Very much whitespace
    assert((("  \t   \n    " * 7) + "Find me if you can" + ("\n" * 28)).strip).equals("Find me if you can")
  end

  it("returns the same string if there is no whitespace to be removed") do
    assert("Yeah".strip).equals("Yeah")
    assert("Ok?".strip).equals("Ok?")
  end
end

describe("String#lstrip") do
  it("returns a new string with all leading whitespace removed") do
    assert("\t\tBye tabs".lstrip).equals("Bye tabs")
  end

  it("preserves trailing whitespace") do
    assert("   Hello \t".lstrip).equals("Hello \t")
  end

  it("if there is no leading whitespace to be removed, the same string is returned") do
    assert("Hello\n".lstrip).equals("Hello\n")
    assert("Hello".lstrip).equals("Hello")
  end
end

describe("String#rstrip") do
  it("returns a new string with all trailing whitespace removed") do
    assert("Nah\n\n\n".rstrip).equals("Nah")
  end

  it("preserves leading whitespace") do
    assert("   Hello \t".rstrip).equals("   Hello")
  end

  it("if there is no trailing whitespace to be removed, the same string is returned") do
    assert("1. d4!!, d5 2. c4!!, dxc4 3. e3!!, b5??".rstrip).equals("1. d4!!, d5 2. c4!!, dxc4 3. e3!!, b5??")
    assert("\n\t¯\_(ツ)_/¯").equals("\n\t¯\_(ツ)_/¯")
  end
end

describe("String#includes") do
  it("Returns true if the string contains given string") do
    assert("Bob fish? yeah".includes?("fish?")).is_true
    assert("Chess is awesome".includes?("Fried liver")).is_false
  end
end

describe("String#[]") do
  str = "Hello"

  describe("with a positive index") do
    it("returns the char at the given index") do
      assert(str[0]).equals("H")
    end

    it("returns nil for an out-of-bounds access") do
      assert(str[10]).is_nil
    end
  end

  describe("with a negative index") do
    it("is 1-based, counting from the end") do
      assert("Bob"[-1]).equals("b")
    end

    it("returns the nth element from the end of the string") do
      assert("123"[-2]).equals("2")
    end

    it("returns nil for out-of-bounds access") do
      assert(str[-str.size - 2]).is_nil
    end
  end

  describe("with a second length argument") do
    it("returns the substring containing `length` characters after the given index") do
      assert(str[0, 3]).equals("Hel")
      assert(str[-2, 2]).equals("lo")
    end

    it("returns the remainder of the string if `length` goes past the end of the string") do
      assert(str[0, 100]).equals("Hello")
    end

    it("returns an empty string if `length` is negative") do
      assert(str[0, -1]).equals("")
    end
  end
end

describe("String#reverse") do
  it("Returns a new string with characters in reverse order") do
    assert("bob".reverse).equals("bob")
    assert("Myst".reverse).equals("tsyM")
    assert("Fish".reverse).equals("hsiF")
  end
end

describe("String#each_char") do
  it("Iterates through each char, passing it to the given block") do
    list = []

    "Fish".each_char { |char| list.push(char) }

    assert(list).equals(["F", "i", "s", "h"])
  end
end
