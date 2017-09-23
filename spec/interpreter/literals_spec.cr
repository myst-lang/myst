require "../spec_helper.cr"
require "../support/interpret.cr"

describe "Interpreter - Literals" do
  it_interprets NilLiteral.new, [TNil.new]

  it_interprets BooleanLiteral.new(true),   [TBoolean.new(true)]
  it_interprets BooleanLiteral.new(false),  [TBoolean.new(false)]

  it_interprets IntegerLiteral.new("1"),    [TInteger.new(1_i64)]
  it_interprets FloatLiteral.new("1.0"),    [TFloat.new(1_f64)]

  it_interprets StringLiteral.new("hello"), [TString.new("hello")]
  it_interprets SymbolLiteral.new("hello"), [TSymbol.new("hello")]
end
