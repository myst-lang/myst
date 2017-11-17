require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - FunctionCapture" do
  it "captures a function from `current_scope` into a Value" do
    itr = parse_and_interpret %q(
      def foo; 1 + 2; end

      # Doing random work to ensure the functor is not the last Value
      # on the stack.
      a = 1
      b = 2

      &foo
    )

    itr.stack.pop.class.should eq(TFunctor)
  end

  it "can be assigned to a variable" do
    itr = parse_and_interpret %q(
      def foo; 1 + 2; end

      a = 1

      bar = &foo
    )

    itr.current_scope["bar"].class.should eq(TFunctor)
  end

  # This is unnecessary, since `fn` naturally returns the newly-created
  # function anyway, but the behavior should be expectable.
  it "can capture anonymous functions" do
    itr = parse_and_interpret %q(
      bar = &fn
        ->() { 1 + 2 }
      end
    )

    itr.stack.pop.class.should eq(TFunctor)
  end

  it "can capture a function from a local variable" do
    itr = parse_and_interpret %q(
      foo = &fn ->() { 1 + 2 } end

      &foo
    )

    itr.stack.pop.class.should eq(TFunctor)
  end

  # Capturing literal values other than functions is allowed by the parser,
  # but is invalid semantically.
  [
    "nil", "true", "false", "1", "1.0",
    "\"hello\"", ":hello", "[]", "{}"
  ].each do |source|
    it "does not allow capturing `#{source}`" do
      itr = interpret_with_mocked_output %Q(&#{source})
      itr.errput.to_s.downcase.should match(/expected a function/)
    end
  end

  it "can capture functions from nested Calls" do
    itr = parse_and_interpret %q(
      defmodule Foo
        def foo
        end
      end

      &Foo.foo
    )

    itr.stack.last.class.should eq(TFunctor)
  end


  it "is treated as a block argument when given at the end of a Call" do
    itr = parse_and_interpret %q(
      def foo(a, b)
        a + b
      end

      def bar(&block)
        block(1, 2)
      end

      bar(&foo)
    )

    itr.stack.last.should eq(val(3))
  end

  it "treats anonymous function captures as block arguments when given at the end of a Call" do
    itr = parse_and_interpret %q(
      def foo(&block)
        block(1, 2)
      end

      foo(&fn
        ->(a, b) { a + b }
      end)
    )

    itr.stack.last.should eq(val(3))
  end
end
