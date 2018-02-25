require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Literals" do
  it_interprets %q(nil), [val(nil)]

  it_interprets %q(true),   [val(true)]
  it_interprets %q(false),  [val(false)]

  it_interprets %q(1),    [val(1)]
  it_interprets %q(1.0),    [val(1.0)]

  it_interprets %q("hello"), [val("hello")]
  it_interprets %q(:hello),  [val(:hello)]

  it_interprets %q([1]),         [TList.new([val(1)])]
  it_interprets %q([1, 2, 3]),   [TList.new([val(1), val(2), val(3)])]
  it_interprets %q([nil, :hi]),  [TList.new([val(nil), val(:hi)])]
  it_interprets %q([[1, 2], [3, 4]]), [TList.new([TList.new([val(1), val(2)]), TList.new([val(3), val(4)])] of MTValue)]

  it_interprets %q({a: 1}),                     [TMap.new({ val(:a) => val(1) })]
  it_interprets %q({<1>: "int", <nil>: :nil}),  [TMap.new({ val(1) => val("int"), val(nil) => val(:nil) })]
  it_interprets %q({<{a: 1}>: {b: 2}}),         [TMap.new({ TMap.new({ val(:a) => val(1) }) => TMap.new({ val(:b) => val(2) }) } of MTValue => MTValue)]
end
