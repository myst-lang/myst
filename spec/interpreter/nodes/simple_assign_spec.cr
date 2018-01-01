require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - SimpleAssign" do
  it "cannot assign to a literal value" do
    # This is already asserted by the parser. It is simply repeated here for
    # completeness.
    expect_raises(ParseError){ parse_and_interpret %q(false = 1) }
  end

  # Assignments should leave the assigned value on the stack
  it_interprets %q(a = 1),          [val(1)]
  it_interprets %q(a = b = {}),     [TMap.new]
  it_interprets %q(THING = nil),    [val(nil)]
  it_interprets %q(_forget = 1.0),  [val(1.0)]

  it "creates an entry in the symbol table for the assigned variable" do
    interpreter = parse_and_interpret %q(a = 1)
    interpreter.current_scope.has_key?("a").should be_true
    interpreter.current_scope["a"].should eq(val(1))
  end

  it "assigns constants" do
    interpreter = parse_and_interpret %q(THING = 2)
    interpreter.current_scope["THING"].should eq(val(2))
  end

  it "does not allow re-assignment to constants" do
    it_does_not_interpret %q(
      THING = 1
      THING = 2
    )
  end
end
