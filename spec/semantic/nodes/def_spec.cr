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
end
