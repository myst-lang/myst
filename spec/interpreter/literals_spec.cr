require "../spec_helper.cr"
require "../support/nodes.cr"
require "../support/interpret.cr"

describe "Interpreter - Literals" do
  it_interprets l(nil), [TNil.new]

  it_interprets l(true),   [TBoolean.new(true)]
  it_interprets l(false),  [TBoolean.new(false)]

  it_interprets l(1),    [TInteger.new(1_i64)]
  it_interprets l(1.0),    [TFloat.new(1_f64)]

  it_interprets l("hello"), [TString.new("hello")]
  it_interprets l(:hello),  [TSymbol.new("hello")]

  it_interprets l([1]),         [TList.new([TInteger.new(1_i64)] of Myst::Value)]
  it_interprets l([1, 2, 3]),   [TList.new([TInteger.new(1_i64), TInteger.new(2_i64), TInteger.new(3_i64)] of Myst::Value)]
  it_interprets l([nil, :hi]),  [TList.new([TNil.new, TSymbol.new("hi")] of Myst::Value)]

  it_interprets l({ :a => 1 }),                       [TMap.new({ TSymbol.new("a") => TInteger.new(1_i64) } of Myst::Value => Myst::Value)]
  it_interprets l({ i(1) => "int", i(nil) => :nil }), [TMap.new({ TInteger.new(1_i64) => TString.new("int"), TNil.new => TSymbol.new("nil") } of Myst::Value => Myst::Value)]
end
