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

  it "assigns to existing values in parent scopes before creating new entries" do
    parent = Scope.new
    parent["a"] = val(1)
    scope = Scope.new(parent)
    # This should look up `a` in the parent scope and re-assign that value.
    scope["a"] = val(2)

    scope.has_key?("a").should be_false
    parent["a"].should eq(val(2))
  end
end
