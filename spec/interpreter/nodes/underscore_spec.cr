require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Underscore" do
  it_interprets %q(_ = 1; _),         [val(1)]
  it_interprets %q(_a = _b = {}; _b), [TMap.new]

  it_interprets %q(_a = 1;_b = 2;_c = 1 + 2; _c), [val(3)]
  it_warns %q(_a = 1;_b = 2;_c = 5 + _b;), 1
  it_warns %q(_a = 1;_b = 2;_c = _a + _b;), 2
end

