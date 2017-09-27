require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Underscore" do
  it_interprets %q(_ = 1; _),         [val(1)]
  it_interprets %q(_a = _b = {}; _b), [TMap.new]
end
