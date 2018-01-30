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

describe("String#chars") do
  it("Returns a List with chars in a string") do
    assert("abc".chars == ["a", "b", "c"])
    assert("yay".chars == ["y", "a", "y"])
  end
end

describe("String#downcase") do
  it("Returns a lowercased version of itself") do
    assert("HELLO".downcase == "hello")
    assert("Bobby Fischer".downcase == "bobby fischer")
    assert("".upcase == "")
    assert("snake_case".downcase == "snake_case")
  end
end

describe("String#upcase") do
  it("Returns a uppercased version of itself") do
    assert("hello".upcase == "HELLO")
    assert("HeLLo AgAIn".upcase == "HELLO AGAIN")
    assert("SCREAMING AM I".upcase == "SCREAMING AM I")
  end
end

describe("String#chomp") do
  it("Returns self with a newline at the end removed when no argument is provided") do
    assert("Bob likes to fish\n".chomp == "Bob likes to fish")
  end

  it("Returns self with specified string removed from the end") do
    assert("Fish does not like to be fish".chomp(" fish") == "Fish does not like to be")
  end
end

describe("String#strip") do
  it("Returns a new string with all leading and trailing whitespace removed") do
    assert("   Hello \t".strip == "Hello")
    assert((("  \t   \n    " * 7) + "Find me if you can" + ("\n" * 28)).strip == "Find me if you can")
  end
end

describe("String#lstrip") do
  it("Returns a new string with all leading whitespace removed") do
    assert("   Hello \t".lstrip == "Hello \t")
    assert("\t\tBye tabs".lstrip == "Bye tabs")
  end
end

describe("String#rstrip") do
  it("Returns a new string with all trailing whitespace removed") do
    assert("   Hello \t".rstrip == "   Hello")
    assert(" Nah\n\n\n".rstrip == " Nah")
  end
end

describe("String#includes") do
  it("Returns true if the string contains given string") do
    assert("Bob fish? yeah".includes?("fish?"))
    refute("Chess is awesome".includes?("Fried liver"))
  end
end

describe("String#[]") do
  str = "Hello"

  it("returns the char at the given index. A negative index is counted from the end of the string. \
    Returns nil if the index falls outside of the string") do

    assert(str[0] + str[-1] == "Ho")    
  end

  it("returns the substring containing length of characters from start. A negative index is counted from the end of the string. \
    Returns nil if the index falls outside of the string") do    
        
    assert(str[0, 3] == "Hel")
    assert(str[-2, 2] + str[2] == "lol") 
  end

  it("returns the element at the given index") do
   assert("12"[0] == "1") 
 end   

 it("returns nil for an out-of-bounds access") do    
   assert("D:"[3] == nil) 
   assert(str[10] == nil)
 end 

 describe("with a negative index") do 
   it("is 1-based, counting from the end") do 
     assert("Bob"[-1] == "b")
   end

   it("returns the nth element from the end of the string") do      
     assert("123"[-2] == "2") 
   end 

   it("returns nil for out-of-bounds access") do 
     str = "yeah, that'd be cool"
     assert(str[-str.size - 2] == nil)
   end 
 end 
end

describe("String#reverse") do 
  it("Returns a new string with characters in reverse order") do
    assert("bob".reverse == "bob") # Oh wait, palindromes are bad test-cases i guess
    assert("Myst".reverse == "tsyM")
    assert("Fish".reverse == "hsiF")
  end
end

describe("String#each_char") do
  it("Iterates through each char, passing it to the given block") do
    list = []

    "Fish".each_char { |char| list.push(char) }

    assert(list == ["F", "i", "s", "h"])
  end
end