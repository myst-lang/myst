require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Const" do
  it_interprets %q(THING = 1; THING),   [val(1)]
  it_interprets %q(A = B = {}; B),      [TMap.new]
end
