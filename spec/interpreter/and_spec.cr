require "../spec_helper.cr"
require "../support/nodes.cr"
require "../support/interpret.cr"

describe "Interpreter - And" do
  # Basic truth table logic
  it_interprets %q(false  &&  false),     [val(false)]
  it_interprets %q(true   &&  false),     [val(false)]
  it_interprets %q(false  &&  true),      [val(false)]
  it_interprets %q(true   &&  true),      [val(true)]

  # When the left side is falsey, that will always be the result.
  it_interprets %q(nil    &&  nil),       [val(nil)]
  it_interprets %q(nil    &&  false),     [val(nil)]
  it_interprets %q(nil    &&  true),      [val(nil)]
  it_interprets %q(nil    &&  1),         [val(nil)]
  it_interprets %q(nil    &&  1.0),       [val(nil)]
  it_interprets %q(nil    &&  ""),        [val(nil)]
  it_interprets %q(nil    &&  :hi),       [val(nil)]
  it_interprets %q(nil    &&  []),        [val(nil)]
  it_interprets %q(nil    &&  {}),        [val(nil)]
  it_interprets %q(false  &&  nil),       [val(false)]
  it_interprets %q(false  &&  false),     [val(false)]
  it_interprets %q(false  &&  true),      [val(false)]
  it_interprets %q(false  &&  1),         [val(false)]
  it_interprets %q(false  &&  1.0),       [val(false)]
  it_interprets %q(false  &&  ""),        [val(false)]
  it_interprets %q(false  &&  :hi),       [val(false)]
  it_interprets %q(false  &&  []),        [val(false)]
  it_interprets %q(false  &&  {}),        [val(false)]

  # When the left side is truthy, the result will always be the right side.
  it_interprets %q(true   && nil),    [val(nil)]
  it_interprets %q(1      && nil),    [val(nil)]
  it_interprets %q(1.0    && nil),    [val(nil)]
  it_interprets %q(""     && nil),    [val(nil)]
  it_interprets %q(:hi    && nil),    [val(nil)]
  it_interprets %q([]     && nil),    [val(nil)]
  it_interprets %q({}     && nil),    [val(nil)]
  it_interprets %q(true   && false),  [val(false)]
  it_interprets %q(1      && false),  [val(false)]
  it_interprets %q(1.0    && false),  [val(false)]
  it_interprets %q(""     && false),  [val(false)]
  it_interprets %q(:hi    && false),  [val(false)]
  it_interprets %q([]     && false),  [val(false)]
  it_interprets %q({}     && false),  [val(false)]

  it_interprets %q(true   &&  nil),   [val(nil)]
  it_interprets %q(true   &&  false), [val(false)]
  it_interprets %q(true   &&  true),  [val(true)]
  it_interprets %q(true   &&  1),     [val(1)]
  it_interprets %q(true   &&  1.0),   [val(1.0)]
  it_interprets %q(true   &&  ""),    [val("")]
  it_interprets %q(true   &&  :hi),   [val(:hi)]
  it_interprets %q(true   &&  []),    [TList.new]
  it_interprets %q(true   &&  {}),    [TMap.new]
  it_interprets %q(true   && false),  [val(false)]

  it_interprets %q(1      && 1.0),    [val(1.0)]
  it_interprets %q(1.0    && " "),    [val(" ")]
  it_interprets %q(""     && :hi),    [val(:hi)]
  it_interprets %q([]     && {}),     [TMap.new]
end
