require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/semantic.cr"

describe "Semantic - Def" do
  it "does nothing for simple Defs" do
    visitor = analyze %q(
      def foo; end
      def bar; end
    )

    visitor.output.to_s.should eq("")
    visitor.errput.to_s.should eq("")
  end

  it "fails when a parameter name is given twice" do
    expect_raises Semantic::Error do
      analyze %q(
        def foo(a, a); end
      )
    end
  end

  it "fails when a parameter name is duplicated under a pattern" do
    expect_raises Semantic::Error do
      analyze %q(
        def foo([a, a]); end
      )
    end
  end

  it "fails when a parameter name is duplicated under different patterns" do
    expect_raises Semantic::Error do
      analyze %q(
        def foo([a, 2, 3], a); end
      )
    end
  end

  it "does not fail when a name is repeated inside a ValueInterpolation" do
    analyze %q(
      def foo(a, <a>); end
    )
  end
end
