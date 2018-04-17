require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Underscore" do
  it "acts like a normal variable for assignment" do
    itr = interpret_with_mocked_output %q(_ = 1; _)
    itr.stack.last.should eq(val(1))
  end

  it "displays a warning when referenced" do
    itr = interpret_with_mocked_output %q(_a = 1;_b = 2;_c = 1 + 2; _c)
    itr.errput.to_s.should match(/Reference to an underscore value `_c`/)
  end

  it "does not fail when referenced" do
    itr = interpret_with_mocked_output %q(_a = 1;_b = 2;_c = 1 + 2; _c)
    itr.stack.last.should eq(val(3))
  end

  # The displayed warning should explain that an underscore should not be referenced.
  it_warns %q(_a = 1;_b = 2;_c = 5 + _b;), /WARNING: Reference to an underscore value `_b`
Underscores indicate that a variable should not be referenced.
If this reference is intentional, consider removing the leading `_`./

  it_warns %q(_a = 1;_b = 2;_c = _a + _b;), /WARNING: Reference to an underscore value `_a`
Underscores indicate that a variable should not be referenced.
If this reference is intentional, consider removing the leading `_`./
end

