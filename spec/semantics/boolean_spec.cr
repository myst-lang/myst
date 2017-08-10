require "../spec_helper.cr"

describe "Boolean Semantics" do
  it "understands equality" do
    assert_true %q(true == true)
    assert_true %q(false == false)
  end

  it "understands inequality" do
    assert_true %q(true != false)
    assert_value %q(true == false), TBoolean.new(false)
  end
end
