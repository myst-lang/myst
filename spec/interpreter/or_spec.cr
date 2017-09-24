require "../spec_helper.cr"
require "../support/nodes.cr"
require "../support/interpret.cr"

describe "Interpreter - Or" do
  # Basic truth table logic
  it_interprets %q(false  ||  false),     [val(false)]
  it_interprets %q(true   ||  false),     [val(true)]
  it_interprets %q(false  ||  true),      [val(true)]
  it_interprets %q(true   ||  true),      [val(true)]

  # When the left side is falsey, the result will always be the right side.
  it_interprets %q(nil    ||  nil),       [val(nil)]
  it_interprets %q(nil    ||  false),     [val(false)]
  it_interprets %q(nil    ||  true),      [val(true)]
  it_interprets %q(nil    ||  1),         [val(1)]
  it_interprets %q(nil    ||  1.0),       [val(1.0)]
  it_interprets %q(nil    ||  ""),        [val("")]
  it_interprets %q(nil    ||  :hi),       [val(:hi)]
  it_interprets %q(nil    ||  []),        [TList.new]
  it_interprets %q(nil    ||  {}),        [TMap.new]
  it_interprets %q(false  ||  nil),       [val(nil)]
  it_interprets %q(false  ||  false),     [val(false)]
  it_interprets %q(false  ||  true),      [val(true)]
  it_interprets %q(false  ||  1),         [val(1)]
  it_interprets %q(false  ||  1.0),       [val(1.0)]
  it_interprets %q(false  ||  ""),        [val("")]
  it_interprets %q(false  ||  :hi),       [val(:hi)]
  it_interprets %q(false  ||  []),        [TList.new]
  it_interprets %q(false  ||  {}),        [TMap.new]

  # When the left side is truthy, that will always be the result.
  it_interprets %q(true   || nil),    [val(true)]
  it_interprets %q(1      || nil),    [val(1)]
  it_interprets %q(1.0    || nil),    [val(1.0)]
  it_interprets %q(""     || nil),    [val("")]
  it_interprets %q(:hi    || nil),    [val(:hi)]
  it_interprets %q([]     || nil),    [TList.new]
  it_interprets %q({}     || nil),    [TMap.new]
  it_interprets %q(true   || false),  [val(true)]
  it_interprets %q(1      || false),  [val(1)]
  it_interprets %q(1.0    || false),  [val(1.0)]
  it_interprets %q(""     || false),  [val("")]
  it_interprets %q(:hi    || false),  [val(:hi)]
  it_interprets %q([]     || false),  [TList.new]
  it_interprets %q({}     || false),  [TMap.new]

  it_interprets %q(true   ||  nil),       [val(true)]
  it_interprets %q(true   ||  false),     [val(true)]
  it_interprets %q(true   ||  true),      [val(true)]
  it_interprets %q(true   ||  1),         [val(true)]
  it_interprets %q(true   ||  1.0),       [val(true)]
  it_interprets %q(true   ||  ""),        [val(true)]
  it_interprets %q(true   ||  :hi),       [val(true)]
  it_interprets %q(true   ||  []),        [val(true)]
  it_interprets %q(true   ||  {}),        [val(true)]
end
