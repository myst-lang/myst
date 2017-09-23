require "./spec_helper.cr"

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
    it "has a type name of Nil" do
      TNil.type_name.should eq("Nil")
    end

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
  end

  describe "TBoolean" do
    it "has a type name of Boolean" do
      TBoolean.type_name.should eq("Boolean")
    end

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
  end

  describe "TInteger" do
    it "has a type name of Integer" do
      TInteger.type_name.should eq("Integer")
    end

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
  end

  describe "TFloat" do
    it "has a type name of Float" do
      TFloat.type_name.should eq("Float")
    end

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
  end

  describe "TString" do
    it "has a type name of String" do
      TString.type_name.should eq("String")
    end

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
  end

  describe "TSymbol" do
    it "has a type name of Symbol" do
      TSymbol.type_name.should eq("Symbol")
    end

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
  end


  describe "TList" do
    it "has a type name of List" do
      TList.type_name.should eq("List")
    end

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
      list.value << TInteger.new(0_i64)
      list.value << TString.new("hello")
    end
  end


  describe "TMap" do
    it "has a type name of Map" do
      TMap.type_name.should eq("Map")
    end

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
      list.value[TBoolean.new(false)] = TInteger.new(0_i64)
      list.value[TBoolean.new(true)]  = TString.new("hello")
    end
  end
end
