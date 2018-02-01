require "../spec_helper.cr"
require "../support/nodes.cr"
require "../support/semantic.cr"

private class FakeNode < Myst::Node
  property? visited : Bool = false

  def accept(visitor)
    @visited = true
  end
end

describe "Semantic - Visitor" do
  describe "#visit" do
    it "recurses through children of the given node" do
      fake_nodes = {FakeNode.new, FakeNode.new, FakeNode.new}
      program = Expressions.new(*fake_nodes)

      analyze(program)

      fake_nodes.each do |node|
        node.visited?.should be_true
      end
    end
  end


  describe "#warn" do
    it "outputs the given message to the errput" do
      visitor = SemanticVisitor.new(errput: IO::Memory.new)
      visitor.warn("some warning")

      visitor.errput.to_s.should eq("some warning\n")
    end
  end


  describe "#fail" do
    it "outputs the given message to the errput" do
      visitor = SemanticVisitor.new(errput: IO::Memory.new)
      begin
        visitor.fail("some warning")
      rescue SemanticError
      end

      visitor.errput.to_s.should eq("some warning\n")
    end

    it "always raises a SemanticError" do
      visitor = SemanticVisitor.new(errput: IO::Memory.new)

      expect_raises(SemanticError) do
        visitor.fail("some warning")
      end
    end
  end
end
