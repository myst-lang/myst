require "../spec_helper.cr"

describe "Values" do
  describe "::from_literal" do
    it "maps NilLiteral to TNil" do
      Myst::Value.from_literal(NilLiteral.new).should be_a(TNil)
    end

    it "maps BooleanLiteral to TBoolean" do
      Myst::Value.from_literal(BooleanLiteral.new(false)).should be_a(TBoolean)
    end

    it "maps IntegerLiteral to TInteger" do
      Myst::Value.from_literal(IntegerLiteral.new("0")).should be_a(TInteger)
    end

    it "maps FloatLiteral to TFloat" do
      Myst::Value.from_literal(FloatLiteral.new("0.0")).should be_a(TFloat)
    end

    it "maps StringLiteral to TString" do
      Myst::Value.from_literal(StringLiteral.new("hello")).should be_a(TString)
    end

    it "maps SymbolLiteral to TSymbol" do
      Myst::Value.from_literal(SymbolLiteral.new("hi")).should be_a(TSymbol)
    end

    # Container values like List and Map require some effort from the
    # interpreter to be generated. As such, Value::from_literal cannot generate
    # them automatically from a node.
    it "does not map ListLiterals" do
      expect_raises { Myst::Value.from_literal(ListLiteral.new).should be_a(TList) }
    end

    it "does not map MapLiterals" do
      expect_raises { Myst::Value.from_literal(MapLiteral.new).should be_a(TMap) }
    end
  end


  describe "TNil" do
    it "has a string representation of `nil`" do
      TNil.new.to_s.should eq("nil")
    end

    it "always references the same object" do
      TNil.new.should be(TNil.new)
    end

    it "is always equal to itself" do
      TNil.new.should eq(TNil.new)
    end

    it "always hashes to the same value" do
      TNil.new.hash.should eq(TNil.new.hash)
    end

    it "is not truthy" do
      TNil.new.truthy?.should eq(false)
    end
  end

  describe "TBoolean" do
    it "always equates FALSE and FALSE" do
      TBoolean.new(false).should eq(TBoolean.new(false))
    end

    it "always equates TRUE and TRUE" do
      TBoolean.new(true).should eq(TBoolean.new(true))
    end

    it "does not equate FALSE and TRUE" do
      TBoolean.new(false).should_not eq(TBoolean.new(true))
    end

    it "always hashes FALSE to the same value" do
      TBoolean.new(false).hash.should eq(TBoolean.new(false).hash)
    end

    it "always hashes TRUE to the same value" do
      TBoolean.new(true).hash.should eq(TBoolean.new(true).hash)
    end

    it "has a string representation of TRUE as `true`" do
      TBoolean.new(true).to_s.should eq("true")
    end

    it "has a string representation of FALSE as `false`" do
      TBoolean.new(false).to_s.should eq("false")
    end

    it "is not truthy when FALSE" do
      TBoolean.new(false).truthy?.should eq(false)
    end

    it "is truthy when TRUE" do
      TBoolean.new(true).truthy?.should eq(true)
    end
  end

  describe "TInteger" do
    it "can contain any 64-bit integer value" do
      TInteger.new( 9_223_372_036_854_775_807)
      TInteger.new(-9_223_372_036_854_775_807)
    end

    it "holds that an integer is equal to itself" do
      TInteger.new(100_i64).should eq(TInteger.new(100_i64))
    end

    it "does not hold that two unique integers are equal" do
      TInteger.new(100_i64).should_not eq(TInteger.new(101_i64))
    end

    it "always hashes equal integers to the same value" do
      TInteger.new(100_i64).hash.should eq(TInteger.new(100_i64).hash)
    end

    it "always hashes unique integers to different values" do
      TInteger.new(100_i64).hash.should_not eq(TInteger.new(101_i64).hash)
    end

    it "can represent its value as a String" do
      TInteger.new( 100_i64).to_s.should eq("100")
      TInteger.new(-100_i64).to_s.should eq("-100")
    end

    it "is always truthy" do
      TInteger.new(0_i64).truthy?.should    eq(true)
      TInteger.new(-100_i64).truthy?.should eq(true)
      TInteger.new(1000_i64).truthy?.should eq(true)
    end
  end

  describe "TFloat" do
    it "can contain any 64-bit float value" do
      TFloat.new( 1.7976931348623157e+308)
      TFloat.new(-1.7976931348623157e+308)
    end

    it "holds that an integer is equal to itself" do
      TFloat.new(100.0_f64).should eq(TFloat.new(100.0_f64))
    end

    it "does not hold that two unique integers are equal" do
      TFloat.new(100.0_f64).should_not eq(TFloat.new(101_f64))
    end

    it "always hashes equal integers to the same value" do
      TFloat.new(100.0_f64).hash.should eq(TFloat.new(100.0_f64).hash)
    end

    it "always hashes unique integers to different values" do
      TFloat.new(100.0_f64).hash.should_not eq(TFloat.new(101_f64).hash)
    end

    it "can represent its value as a String" do
      TFloat.new( 100.0_f64).to_s.should eq("100.0")
      TFloat.new(-100.0_f64).to_s.should eq("-100.0")
    end

    it "is always truthy" do
      TFloat.new(0.0_f64).truthy?.should    eq(true)
      TFloat.new(-100.0_f64).truthy?.should eq(true)
      TFloat.new(1000.0_f64).truthy?.should eq(true)
    end
  end

  describe "TString" do
    it "can contain strings of arbitrary length" do
      TString.new("hello"*1000)
    end

    it "can contain escape sequences" do
      TString.new("\n")
    end

    it "holds that a string is equal to itself" do
      TString.new("hi").should eq(TString.new("hi"))
    end

    it "always hashes a string to the same value" do
      TString.new("hi").hash.should eq(TString.new("hi").hash)
    end

    it "always hashes unique strings to different values" do
      TString.new("hi").hash.should_not eq(TString.new("hello"))
    end

    it "uses its value as its string representation" do
      TString.new("hello").to_s.should eq("hello")
    end

    it "interprets escape sequences in its string representation" do
      TString.new("\nhi\n").to_s.should eq("
hi
")
    end

    it "is always truthy" do
      TString.new("").truthy?.should            eq(true)
      TString.new("\n").truthy?.should          eq(true)
      TString.new("\0").truthy?.should          eq(true)
      TString.new("hello world").truthy?.should eq(true)
    end
  end

  describe "TSymbol" do
    it "can be created from any string value" do
      TSymbol.new("hello"*1000)
      TSymbol.new("hello\n\t\0")
    end

    it "always refers to the same object for the same name" do
      TSymbol.new("hello").should be(TSymbol.new("hello"))
    end

    it "always considers a symbol equal to itself" do
      TSymbol.new("hello").should eq(TSymbol.new("hello"))
    end

    it "never considers two unique symbols equal" do
      TSymbol.new("hi").should_not eq(TSymbol.new("hello"))
    end

    it "is always truthy" do
      TSymbol.new("").truthy?.should            eq(true)
      TSymbol.new("\n").truthy?.should          eq(true)
      TSymbol.new("\0").truthy?.should          eq(true)
      TSymbol.new("hello world").truthy?.should eq(true)
    end
  end


  describe "TList" do
    it "can be created with no elements" do
      TList.new
    end

    it "can be created with initial elements" do
      TList.new([TNil.new, TNil.new] of Myst::Value)
    end

    it "can contain any mixture of Values" do
      TList.new([TInteger.new(1_i64), TBoolean.new(false), TString.new("hello")])
    end

    it "can contain other lists within itself" do
      TList.new([TList.new, TList.new] of Myst::Value)
    end

    it "can dynamically adjust its size" do
      list = TList.new
      list.elements << TInteger.new(0_i64)
      list.elements << TString.new("hello")

      list.elements.size.should eq(2)
    end

    it "is always truthy" do
      TList.new.truthy?.should                                        eq(true)
      TList.new([TNil.new] of Myst::Value).truthy?.should             eq(true)
      TList.new([TBoolean.new(false)] of Myst::Value).truthy?.should  eq(true)
      TList.new([TInteger.new(1_i64), TNil.new]).truthy?.should       eq(true)
    end
  end


  describe "TMap" do
    it "can be created with no elements" do
      TMap.new
    end

    it "can be created with initial elements" do
      TMap.new({ TNil.new => TNil.new } of Myst::Value => Myst::Value)
    end

    it "can contain any mixture of Values" do
      TMap.new({ TInteger.new(1_i64) => TBoolean.new(false), TString.new("hello") => TSymbol.new("hi")})
    end

    it "can contain other maps within itself" do
      TMap.new({ TMap.new => TMap.new } of Myst::Value => Myst::Value)
    end

    it "can dynamically adjust its size" do
      list = TMap.new
      list.entries[TBoolean.new(false)] = TInteger.new(0_i64)
      list.entries[TBoolean.new(true)]  = TString.new("hello")

      list.entries.size.should eq(2)
    end

    it "is always truthy" do
      TMap.new.truthy?.should eq(true)
      TMap.new({ TNil.new => TNil.new } of Myst::Value => Myst::Value).truthy?.should eq(true)
      TMap.new({ TSymbol.new("") => TInteger.new(1_i64) } of Myst::Value => Myst::Value).truthy?.should eq(true)
    end
  end
end
