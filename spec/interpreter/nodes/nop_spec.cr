require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Nop" do
  # For completeness
  it "does nothing" do
    itr = Interpreter.new
    itr.visit(Nop.new)
    itr.visit(Expressions.new(Nop.new, Nop.new, Nop.new))
  end
end
