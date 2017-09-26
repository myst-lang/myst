require "../spec_helper.cr"

describe "Interpreter - Scope" do
  it "acts like a Hash" do
    scope = Scope.new
    scope["a"] = val(1)
    scope["a"].should eq(val(1))
    expect_raises(IndexError) do
      scope["b"]
    end

    scope["b"]?.should be(nil)
  end

  describe "#[]" do
    it "looks up values through parent scopes" do
      parent = Scope.new
      parent["a"] = val(1)
      scope = Scope.new(parent)
      scope["a"].should eq(val(1))
    end

    it "assigns to existing values in parent scopes before creating new entries" do
      parent = Scope.new
      parent["a"] = val(1)
      scope = Scope.new(parent)
      # This should look up `a` in the parent scope and re-assign that value.
      scope["a"] = val(2)

      parent["a"].should eq(val(2))
    end
  end

  describe "#has_key?" do
    it "only checks itself for an entry" do
      parent = Scope.new
      parent["a"] = val(1)
      scope = Scope.new(parent)

      scope.has_key?("a").should be_false
    end

    it "Returns falsey when the current scope does not have a value" do
      scope = Scope.new
      scope.has_key?("a").should be_false
    end
  end

  describe "#assign" do
    it "does not check parent scopes for existing entries" do
      parent = Scope.new
      parent["a"] = val(1)
      scope = Scope.new(parent)

      scope.assign("a", val(2))
      # The scope should create a new entry with the value 2.
      scope["a"].should eq(val(2))
      # While the parent scope remains untouched.
      parent["a"].should eq(val(1))
    end

    it "returns the value that was assigned" do
      scope = Scope.new
      (scope["a"] = val(1)).should eq(val(1))
    end
  end
end
