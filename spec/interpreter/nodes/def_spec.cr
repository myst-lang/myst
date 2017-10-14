require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Def" do
  # The result of a `def` should always be the function that was defined.
  it_interprets %q(def foo; end)  { |itr| [TFunctor.new([TFunctorDef.new(Def.new("foo"))] of Callable, itr.current_scope)] }
  it_interprets %q(
    def foo
      []
    end
  )                               { |itr| [TFunctor.new([TFunctorDef.new(Def.new("foo", body: e(ListLiteral.new)))] of Callable, itr.current_scope)] }
  it_interprets %q(
    def foo
      true
      nil
      1
    end
  )                               { |itr| [TFunctor.new([TFunctorDef.new(Def.new("foo", body: e(l(true), l(nil), l(1))))] of Callable, itr.current_scope)] }

  it_interprets %q(
    def foo(a)
      a
    end
  )                               { |itr| [TFunctor.new([TFunctorDef.new(Def.new("foo", [p("a")], body: e(Var.new("a"))))] of Callable, itr.current_scope)] }

  # Redefinition of a function is allowed. It will simply create a second clause.
  it_interprets %q(
    def foo; end
    def foo; end
  )                               { |itr| [TFunctor.new([TFunctorDef.new(Def.new("foo")), TFunctorDef.new(Def.new("foo"))] of Callable, itr.current_scope)] }

  it_interprets %q(
    def foo(a); end
    def foo(b); end
  )                               { |itr| [TFunctor.new([TFunctorDef.new(Def.new("foo", [p("a")])), TFunctorDef.new(Def.new("foo", [p("b")]))] of Callable, itr.current_scope)] }

  # Functions with different names should not be merged into one functor.
  it_interprets %q(
    def a; end
    def b; end
  )                               { |itr| [TFunctor.new([TFunctorDef.new(Def.new("b"))] of Callable, itr.current_scope)] }

  it "only checks the current scope for existing functors" do
    itr = Interpreter.new
    itr.current_scope["foo"] = TFunctor.new([] of Callable, itr.current_scope)
    itr.push_self(TModule.new)
    # With the new scope, the current scope does not have `foo` defined.
    itr.current_scope.has_key?("foo").should be_false
    # `def foo`, then, shouldn't find the existing functor from the parent
    # scope, and will instead create a new value.
    parse_and_interpret %q(def foo; end), itr
    # That value should then be stored in the current scope.
    itr.current_scope.has_key?("foo").should be_true
  end
end
