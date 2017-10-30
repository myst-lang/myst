require "../spec_helper.cr"

describe "Interpreter - ClosureScope" do
  it "acts like a Hash" do
    scope = ClosureScope.new(Scope.new)
    scope["a"] = val(1)
    scope["a"].should eq(val(1))
    expect_raises(IndexError) do
      scope["b"]
    end

    scope["b"]?.should be(nil)
  end

  describe "#[]" do
    it "looks up values in the parent scope" do
      parent = Scope.new
      parent["a"] = val(1)
      scope = ClosureScope.new(parent)
      scope["a"].should eq(val(1))
    end

    it "does not look beyond the closured scope" do
      grandparent = Scope.new
      grandparent["a"] = val(1)
      parent = Scope.new(grandparent)
      scope = ClosureScope.new(parent)

      expect_raises(IndexError) do
        scope["a"]
      end
    end

    it "assigns to existing values in parent scopes before creating new entries" do
      parent = Scope.new
      parent["a"] = val(1)
      scope = ClosureScope.new(parent)
      # This should look up `a` in the parent scope and re-assign that value.
      scope["a"] = val(2)

      parent["a"].should eq(val(2))
    end
  end

  describe "#has_key?" do
    it "checks itself for an entry" do
      scope = ClosureScope.new(Scope.new)
      scope["a"] = val(1)

      scope.has_key?("a").should be_true
    end

    it "checks the closured scope for an entry" do
      parent = Scope.new
      parent["a"] = val(1)
      scope = ClosureScope.new(parent)

      scope.has_key?("a").should be_true
    end

    it "Returns falsey when the current scope does not have a value" do
      scope = ClosureScope.new(Scope.new)
      scope.has_key?("a").should be_false
    end
  end

  describe "#assign" do
    it "assigns to the parent scope for existing entries" do
      parent = Scope.new
      parent["a"] = val(1)
      scope = ClosureScope.new(parent)

      scope.assign("a", val(2))
      # The closure scope should synchronize with the parent.
      scope["a"].should eq(val(2))
      parent["a"].should eq(val(2))
    end

    it "assigns to itself for new entries" do
      parent = Scope.new
      scope = ClosureScope.new(parent)

      scope.assign("a", val(2))
      scope["a"].should eq(val(2))
      parent["a"]?.should be_nil
    end

    it "returns the value that was assigned" do
      scope = ClosureScope.new(Scope.new)
      (scope["a"] = val(1)).should eq(val(1))
    end
  end


  describe "#clear" do
    it "removes all entries from the scope" do
      scope = ClosureScope.new(Scope.new)
      scope["a"] = TNil.new
      scope["Thing"] = TType.new("Thing")
      scope["x"] = TInteger.new(100_i64)

      scope.values.size.should eq(3)

      scope.clear

      scope.values.size.should eq(0)
      scope.has_key?("a").should be_false
      scope.has_key?("Thing").should be_false
      scope.has_key?("x").should be_false
    end

    it "does not remove values from the closured scope" do
      parent = Scope.new
      parent["a"] = val(1)
      scope = ClosureScope.new(parent)
      scope["b"] = val(2)

      scope.values.size.should eq(1)

      scope.clear

      scope.values.size.should eq(0)
      parent["a"].should eq(val(1))
    end
  end


  describe "when nested" do
    it "can access values from the outermost closured scope" do
      grandparent = Scope.new
      grandparent["a"] = val(1)
      parent = ClosureScope.new(grandparent)
      scope = ClosureScope.new(parent)

      scope["a"].should eq(val(1))
    end
  end
end
