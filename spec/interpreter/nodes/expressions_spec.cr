require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Expressions" do
  # With multiple expressions in a block, only the result of the last
  # expression is left on the stack.
  it_interprets %q(true),  [val(true)]
  it_interprets %q(1; 2),  [val(2)]
  it_interprets %q(nil; false; true; 1; 2; 3),  [val(3)]
end
