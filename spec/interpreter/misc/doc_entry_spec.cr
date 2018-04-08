require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - DocEntry" do
  describe "#basename" do
    it "returns the last component of a simple reference" do
      entry = DocEntry.new("foo", nil, "")

      entry.basename.should eq("foo")
    end

    it "returns the last component of a static reference path" do
      entry = DocEntry.new("foo", nil, "")

      entry.basename.should eq("foo")
    end

    it "returns the last component of an instance reference path" do
      entry = DocEntry.new("foo", nil, "")

      entry.basename.should eq("foo")
    end

    it "returns the last component of a mixed reference path" do
      entry = DocEntry.new("foo", nil, "")

      entry.basename.should eq("foo")
    end

    it "returns the last component of a deep reference path" do
      entry = DocEntry.new("A.B.C.D#foo", nil, "")

      entry.basename.should eq("foo")
    end

    it "works with types as the last component" do
      entry = DocEntry.new("A.B.C.Foo", nil, "")

      entry.basename.should eq("Foo")
    end


    it "preserves query modifiers on method names" do
      entry = DocEntry.new("foo?", nil, "")

      entry.basename.should eq("foo?")
    end

    it "preserves bang modifiers on method names" do
      entry = DocEntry.new("foo!", nil, "")

      entry.basename.should eq("foo!")
    end

    it "preserves underscores on method names" do
      entry = DocEntry.new("_foo__", nil, "")

      entry.basename.should eq("_foo__")
    end
  end
end
