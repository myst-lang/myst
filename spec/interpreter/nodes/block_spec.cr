require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Block" do
  # Blocks are mainly identical to Defs, except they should always instantiate
  # a new functor, and the result should not be assigned in the current scope.
  it "does not assign the block into the current scope" do
    # # TODO: revisit this spec when closures are properly implemented
    # next
    # Ensure a clean slate for the test (no kernel, etc.)
    itr = Interpreter.new
    itr.current_scope.clear

    parse_and_interpret %q(
      def foo(&block)
        block
      end

      foo{ }
    ), itr
    itr.current_scope.values.size.should eq(1)
  end

  it "creates a new functor for each block" do
    itr = parse_and_interpret %q(
      def foo(&block)
        block
      end

      foo{ 1 }
      foo{ 2 }
    )

    itr.stack.pop.should eq(val(2))
  end

  it "creates a closure of the environment it is defined in" do
    itr = parse_and_interpret %q(
      def foo(&block)
        block(1)
        block(2)
        block(3)
      end

      x = 0
      foo do |i|
        x = x + i
      end
      x
    )

    itr.stack.pop.should eq(val(6))
  end
end
