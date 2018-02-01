require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/semantic.cr"

describe "Semantic Assertions - Duplicate Param Names" do
  it "does nothing for simple Defs" do
    visitor = analyze %q(
      def foo; end
      def bar; end
    )

    visitor.output.to_s.should eq("")
    visitor.errput.to_s.should eq("")
  end

  it "fails when a name is given twice" do
    expect_semantic_failure %q(
      def foo(a, a); end
    ), /parameter `a` is bound more than once/
  end

  it "fails when a name is duplicated under a pattern" do
    expect_semantic_failure %q(
      def foo([a, a]); end
    ), /parameter `a` is bound more than once/
  end

  it "fails when a name is duplicated under different patterns" do
    expect_semantic_failure %q(
      def foo([a, 2, 3], a); end
    ), /parameter `a` is bound more than once/
  end

  it "fails when a name is duplicated more than once" do
    expect_semantic_failure %q(
      def foo(a, a, a, a); end
    ), /parameter `a` is bound more than once/
  end

  it "fails on the first instance of a duplicate" do
    expect_semantic_failure %q(
      def foo(a, b, a, b); end
    ), /parameter `a` is bound more than once/
  end

  it "passes when a name is used in an interpolation" do
    analyze %q(
      def foo(a, <a>); end
    )
  end


  describe "suggested resolution" do
    it "replaces duplicates with ValueInterpolations" do
      expect_semantic_failure %q(
        def foo(a, a); end
      ), /def foo\(a, \<a\>\)/
    end

    it "replaces multiple duplicates with ValueInterpolations" do
      expect_semantic_failure %q(
        def foo(a, a, a, a); end
      ), /def foo\(a, \<a\>, \<a\>, \<a\>\)/
    end

    it "only replaces duplicates" do
      expect_semantic_failure %q(
        def foo(a, b, c, a); end
      ), /def foo\(a, b, c, \<a\>\)/
    end
  end
end
