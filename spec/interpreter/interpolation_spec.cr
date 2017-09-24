require "../spec_helper.cr"
require "../support/nodes.cr"
require "../support/interpret.cr"

describe "Interpreter - Interpolation" do
  it_interprets i(nil), [val(nil)]

  it_interprets i(true),   [val(true)]
  it_interprets i(false),  [val(false)]

  it_interprets i(1),    [val(1)]
  it_interprets i(1.0),    [val(1.0)]

  it_interprets i("hello"), [val("hello")]
  it_interprets i(:hello),  [val(:hello)]

  it_interprets i([1]),         [TList.new([val(1)])]
  it_interprets i([1, 2, 3]),   [TList.new([val(1), val(2), val(3)])]
  it_interprets i([nil, :hi]),  [TList.new([val(nil), val(:hi)])]
  it_interprets i([[1, 2], [3, 4]]), [TList.new([TList.new([val(1), val(2)]), TList.new([val(3), val(4)])] of Myst::Value)]

  it_interprets i({ :a => 1 }),                       [TMap.new({ val(:a) => val(1) })]
  it_interprets i({ i(1) => "int", i(nil) => :nil }), [TMap.new({ val(1) => val("int"), val(nil) => val(:nil) })]
  it_interprets i({ {:a => 1 } => { :b => 2 } }),     [TMap.new({ TMap.new({ val(:a) => val(1) }) => TMap.new({ val(:b) => val(2) }) } of Myst::Value => Myst::Value)]

  it_interprets %q(<(true   && true)>),   [val(true)]
  it_interprets %q(<(false  && true)>),   [val(false)]
  it_interprets %q(<(false  || true)>),   [val(true)]
  it_interprets %q(<(true   || true)>),   [val(true)]
end
