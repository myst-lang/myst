require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - OpUnary" do
  it "handle negation for integers" do
    it_interprets %q(a = 2 + -1; a), [val(1)]
    it_interprets %q(a = -2 + -1;), [val(-3)]
  end
  
  it "handle negation for floats" do
    it_interprets %q(-2.23 + 1), [val(-1.23)]
    it_interprets %q(-2.23 + 1.1), [val(-1.13)]
  end

  it "handle negation for floats" do
    it_interprets %q(!true), [val(false)]
    it_interprets %q(not true), [val(false)]
  end
end
