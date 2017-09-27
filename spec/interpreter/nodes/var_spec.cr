require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Var" do
  it_interprets %q(a = 1; a),       [val(1)]
  it_interprets %q(a = b = {}; b),  [TMap.new]
end
