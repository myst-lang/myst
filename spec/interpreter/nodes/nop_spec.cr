require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Nop" do
  # For completeness
  it_interprets Nop.new,  [] of Myst::Value
  it_interprets Expressions.new(Nop.new, Nop.new, Nop.new), [] of Myst::Value
end
