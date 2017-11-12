require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - OpUnary" do
  it "handle negation" do
    it_interprets %q(a = 2 + -1; a), [val(1)]
  end
end
