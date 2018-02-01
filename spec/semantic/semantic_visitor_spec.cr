require "../spec_helper.cr"
require "../support/nodes.cr"
require "../support/semantic.cr"

describe "Semantic - Visitor" do
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
