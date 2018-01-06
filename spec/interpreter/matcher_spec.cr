require "../spec_helper.cr"
require "../support/nodes.cr"
require "../support/interpret.cr"

private macro it_matches(pattern, value, setup=nil)
  it %q(matches `{{pattern}}` and `{{value}}`) do
    itr = Interpreter.new
    result = itr.match({{pattern}}, {{value}})

    {{yield}}
  end
end

private macro it_does_not_match(pattern, value)
  it %q(does not match `{{pattern}}` and `{{value}}`) do
    expect_raises(MatchError) do
      itr = Interpreter.new
      result = itr.match({{pattern}}, {{value}})
    end
  end
end

describe "Interpreter - #match" do
  it_matches l(nil),    val(nil)
  it_matches l(true),   val(true)
  it_matches l(false),  val(false)
  it_matches l(1),      val(1)
  it_matches l(1.0),    val(1.0)
  it_matches l("hi"),   val("hi")
  it_matches l(:hi),    val(:hi)

  # Integer and Floats can be matched when the Float has no decimal precision.
  it_matches l(1),      val(1.0)
  it_matches l(1.0),    val(1)
  it_does_not_match l(1.01),    val(1)
  it_does_not_match l(1),       val(1.01)
  it_does_not_match l(nil),     val(false)
  it_does_not_match l(nil),     val(true)
  it_does_not_match l(nil),     val(true)
  it_does_not_match l(true),    val(false)
  it_does_not_match l(false),   val(true)
  it_does_not_match l(1),       val("1")
  it_does_not_match l(1),       val(:"1")
  it_does_not_match l(:hi),     val("hi")


  # List matching is exhaustive. All elements in the value _must_ be captured
  # in some way by the pattern.
  it_matches ListLiteral.new,         TList.new
  it_matches l([1, 2, "hi"]),         val([1, 2, "hi"])
  it_does_not_match ListLiteral.new,  val([1, 2])
  it_does_not_match l([1, 2]),        val([1, 2, 3, 4])


  # Map matching is not exhaustive. As long as the value contains _at least_
  # the entries defined in the pattern, the match succeeds.
  it_matches MapLiteral.new,              TMap.new
  it_matches l({:a => 1}),                val({:a => 1, :b => 2})
  it_matches l({:b => 2}),                val({:a => 1, :b => 2})
  it_matches l({:a => 1, i(1) => "hi"}),  val({:a => 1, 1 => "hi"})
  it_matches MapLiteral.new,              val({:a => 1, :b => 2})
  # But, if the pattern has a key that the value does not, the match fails.
  it_does_not_match l({:a => 1}),           TMap.new
  it_does_not_match l({:a => 1, :b => 2}),  val({:a => 1})


  # Vars should always be assigned into the current scope.
  it_matches v("a"),    val(1.0) do
    itr.current_scope.has_key?("a").should be_true
    itr.current_scope["a"].should eq(val(1.0))
  end

  it_matches v("a"),    val([1, 2]) do
    itr.current_scope.has_key?("a").should be_true
    itr.current_scope["a"].should eq(val([1, 2]))
  end

  # The Var can appear at any point in the pattern.
  it_matches l([1, v("a")]),  val([1, 2]) do
    itr.current_scope.has_key?("a").should be_true
    itr.current_scope["a"].should eq(val(2))
  end

  it_matches l([[1, [v("a"), 3]], 4]), val([[1, [2, 3]], 4]) do
    itr.current_scope.has_key?("a").should be_true
    itr.current_scope["a"].should eq(val(2))
  end

  it_matches l({:a => v("a")}), val({:a => "hello"}) do
    itr.current_scope.has_key?("a").should be_true
    itr.current_scope["a"].should eq(val("hello"))
  end

  # Underscores also get assigned.
  it_matches l([u("_"), u("_another")]), val([1, 2]) do
    itr.current_scope.has_key?("_").should be_true
    itr.current_scope["_"].should eq(val(1))
    itr.current_scope.has_key?("_another").should be_true
    itr.current_scope["_another"].should eq(val(2))
  end


  # ValueInterpolations are treated as a single Value to match against.
  it_matches i([1, 2]),                       val([1, 2])
  it_matches i(false),                        val(false)
  it_matches i(Call.new(l(1), "+", [l(2)])),  val(3)
  it_matches i(Call.new(l(1), "-", [l(2)])),  val(-1)

  it "can interpolate Vars in patterns" do
    itr = Interpreter.new
    itr.current_scope.assign("a", val(1))
    itr.match(i(v("a")), val(1))
  end

  it "does not re-assign Vars in interpolations in patterns" do
    itr = Interpreter.new
    itr.current_scope.assign("a", val(1))

    expect_raises(MatchError) do
      itr.match(i(v("a")), val(2))
    end
    # The value of `a` should not have changed from the match.
    itr.current_scope["a"].should eq(val(1))
  end

  # Consts can be used to match the type of a value.
  it_matches c("Integer"),  val(1)
  it_matches c("List"),     TList.new
  it_matches c("String"),   val("hello world")
  it_matches c("Nil"),      val(nil)
end
