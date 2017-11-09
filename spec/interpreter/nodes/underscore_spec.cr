require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Underscore" do
  it_interprets %q(_ = 1; _),         [val(1)]
  it_interprets %q(_a = _b = {}; _b), [TMap.new]

  # Underscore reference UTs
  ## Continue parsing. It's only a warning, prg must compile and return value
  it_interprets %q(_a = 1;_b = 2;_c = 1 + 2; _c), [val(3)]
  ## Simply test for number of warnings
  it_warns %q(_a = 1;_b = 2;_c = 5 + _b;), 1
  it_warns %q(_a = 1;_b = 2;_c = _a + _b;), 2
end

