require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Doc comments" do
  it "attaches documentation to a function definition" do
    itr = parse_and_interpret %q(
      # Docs for foo.
      def foo; end
    )

    foo = itr.current_scope["foo"]
    itr.__docs_for(foo).should eq("Docs for foo.")
  end

  it "does not override existing documentation on new function clauses" do
    itr = parse_and_interpret %q(
      # Docs for foo.
      def foo; end

      # Not new docs for foo.
      def foo; end
    )

    foo = itr.current_scope["foo"]
    itr.__docs_for(foo).should eq("Docs for foo.")
  end

  it "does not add new documentation if the functor already exists" do
    itr = parse_and_interpret %q(
      def foo; end

      # Not new docs for foo.
      def foo; end
    )

    foo = itr.current_scope["foo"]
    itr.__docs_for(foo).should eq(TNil.new)
  end
end
