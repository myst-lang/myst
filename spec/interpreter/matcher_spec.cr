require "../spec_helper.cr"
require "../support/nodes.cr"
require "../support/interpret.cr"


def it_matches(pattern, value)
  it "accepts `#{pattern}` and `#{value}`" do
    itr = Interpreter.new
    itr.match(pattern, value)
  end
end

# These tests simply assert the interface of the Matcher class. The semantics
# of matching are primarily tested under `nodes/match_assign_spec.cr`.
describe "Interpreter - Matcher" do
  describe "#match" do
    it_matches l(nil),    val(nil)
    it_matches l(true),   val(true)
    it_matches l(false),  val(false)
    it_matches l(1),      val(1)
    it_matches l(1.0),    val(1.0)
    it_matches l("hi"),   val("hi")
    it_matches l(:hi),    val(:hi)

    it_matches ListLiteral.new, TList.new
    it_matches l([1, 2, "hi"]), val([1, 2, "hi"])
    it_matches MapLiteral.new,  TMap.new
    it_matches l({:a => 1, i(1) => "hi"}), val({:a => 1, 1 => "hi"})

    # Values of different types should be allowed to match.
    it_matches l(nil),    val(false)
    it_matches l(true),   val(1.0)
    it_matches l("hi"),   val(:hi)
  end
end
