require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Return" do
  it "causes a function to return immediately" do
    itr = parse_and_interpret %q(
      def foo
        return 1
        2
      end

      foo
    )

    itr.stack.pop.should eq(val(1))
  end

  it "returns nil when no value is given" do
    itr = parse_and_interpret %q(
      def foo
        return
        2
      end

      foo
    )

    itr.stack.pop.should eq(val(nil))
  end
end
