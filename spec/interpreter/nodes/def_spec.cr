require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Def" do
  # The result of a `def` should always be the function that was defined.
  it_interprets %q(def foo; end), [TFunctor.new(itr.current_scope, [Def.new("foo")])]
  it_interprets %q(
    def foo
      []
    end
  ),                              [TFunctor.new(itr.current_scope, [Def.new("foo", body: e(ListLiteral.new))])]
  it_interprets %q(
    def foo
      true
      nil
      1
    end
  ),                              [TFunctor.new(itr.current_scope, [Def.new("foo", body: e(l(true), l(nil), l(1)))])]

  # Redefinition of a function is allowed. It will simply create a second clause.
  it_interprets %q(
    def foo; end
    def foo; end
  ),                              [TFunctor.new(itr.current_scope, [Def.new("foo"), Def.new("foo")])]

  # Functions with different names should not be merged into one functor.
  it_interprets %q(
    def a; end
    def b; end
  ),                              [TFunctor.new(itr.current_scope, [Def.new("b")])]
end
