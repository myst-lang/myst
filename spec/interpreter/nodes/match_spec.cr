require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Match" do
  it "acts like a closure" do
    itr = parse_and_interpret %q(
      a = 1
      match 2
        ->(b) { a + b }
      end
    )

    itr.stack.last.should eq(val(3))
  end

  it "invokes the appropriate clause based on pattern matching" do
    itr = parse_and_interpret %q(
      match 1
        ->(0) { :zero }
        ->(1) { :one }
        ->(2) { :two }
      end
    )

    itr.stack.last.should eq(val(:one))
  end

  it "matches multiple arguments as separate parameters" do
    itr = parse_and_interpret %q(
      match 1, 2, 3
        ->([1, 2, 3]) { :nope }
        ->(1, 2, 3) { :yes }
      end
    )

    itr.stack.last.should eq(val(:yes))
  end

  it "raises an error if no clause matches" do
    itr = interpret_with_mocked_output %q(
      match 1
        ->(2) { }
      end
    )

    itr.errput.to_s.downcase.should match(/no clause matches/)
  end
end
