require "../spec_helper.cr"
require "../support/nodes.cr"
require "../support/interpret.cr"

describe "Interpreter - Literals" do
  it_interprets l(nil), [val(nil)]

  it_interprets l(true),   [val(true)]
  it_interprets l(false),  [val(false)]

  it_interprets l(1),    [val(1)]
  it_interprets l(1.0),    [val(1.0)]

  it_interprets l("hello"), [val("hello")]
  it_interprets l(:hello),  [val(:hello)]

  it_interprets l([1]),         [TList.new([val(1)])]
  it_interprets l([1, 2, 3]),   [TList.new([val(1), val(2), val(3)])]
  it_interprets l([nil, :hi]),  [TList.new([val(nil), val(:hi)])]
  it_interprets l([[1, 2], [3, 4]]), [TList.new([TList.new([val(1), val(2)]), TList.new([val(3), val(4)])] of Myst::Value)]

  it_interprets l({ :a => 1 }),                       [TMap.new({ val(:a) => val(1) })]
  it_interprets l({ i(1) => "int", i(nil) => :nil }), [TMap.new({ val(1) => val("int"), val(nil) => val(:nil) })]
  it_interprets l({ {:a => 1 } => { :b => 2 } }),     [TMap.new({ TMap.new({ val(:a) => val(1) }) => TMap.new({ val(:b) => val(2) }) } of Myst::Value => Myst::Value)]
end
