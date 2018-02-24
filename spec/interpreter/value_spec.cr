require "../spec_helper.cr"

describe "Values" do
  describe "::from_literal" do
    it "maps NilLiteral to TNil" do
      Interpreter.__value_from_literal(NilLiteral.new).should be_a(TNil)
    end

    it "maps BooleanLiteral to Bool" do
      Interpreter.__value_from_literal(BooleanLiteral.new(false)).should be_a(Bool)
    end

    it "maps IntegerLiteral to Int64" do
      Interpreter.__value_from_literal(IntegerLiteral.new("0")).should be_a(Int64)
    end

    it "maps FloatLiteral to Float64" do
      Interpreter.__value_from_literal(FloatLiteral.new("0.0")).should be_a(Float64)
    end

    it "maps StringLiteral to String" do
      Interpreter.__value_from_literal(StringLiteral.new("hello")).should be_a(String)
    end

    it "maps SymbolLiteral to TSymbol" do
      Interpreter.__value_from_literal(SymbolLiteral.new("hi")).should be_a(TSymbol)
    end

    # Container values like List and Map require some effort from the
    # interpreter to be generated. As such, Value::from_literal cannot generate
    # them automatically from a node.
    it "does not map ListLiterals" do
      expect_raises(Exception) { Interpreter.__value_from_literal(ListLiteral.new).should be_a(TList) }
    end

    it "does not map MapLiterals" do
      expect_raises(Exception) { Interpreter.__value_from_literal(MapLiteral.new).should be_a(TMap) }
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
      TList.new([TNil.new, TNil.new] of MTValue)
    end

    it "can contain any mixture of Values" do
      TList.new([1_i64, false, "hello"] of MTValue)
    end

    it "can contain other lists within itself" do
      TList.new([TList.new, TList.new] of MTValue)
    end

    it "can dynamically adjust its size" do
      list = TList.new
      list.elements << 0_i64
      list.elements << "hello"

      list.elements.size.should eq(2)
    end

    it "is always truthy" do
      TList.new.truthy?.should                        eq(true)
      TList.new([TNil.new] of MTValue).truthy?.should eq(true)
      TList.new([false] of MTValue).truthy?.should    eq(true)
      TList.new([1_i64, TNil.new] of MTValue).truthy?.should     eq(true)
    end
  end


  describe "TMap" do
    it "can be created with no elements" do
      TMap.new
    end

    it "can be created with initial elements" do
      TMap.new({ TNil.new => TNil.new } of MTValue => MTValue)
    end

    it "can contain any mixture of Values" do
      TMap.new({ 1_i64 => false, "hello" => "hi" } of MTValue => MTValue)
    end

    it "can contain other maps within itself" do
      TMap.new({ TMap.new => TMap.new } of MTValue => MTValue)
    end

    it "can dynamically adjust its size" do
      list = TMap.new
      list.entries[false] = 0_i64
      list.entries[true]  = "hello"

      list.entries.size.should eq(2)
    end

    it "is always truthy" do
      TMap.new.truthy?.should eq(true)
      TMap.new({ TNil.new => TNil.new } of MTValue => MTValue).truthy?.should eq(true)
      TMap.new({ TSymbol.new("") => 1_i64 } of MTValue => MTValue).truthy?.should eq(true)
    end
  end
end
