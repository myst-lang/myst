require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Self" do
  it "returns the value of `current_self`" do
    itr = parse_and_interpret %q(
      deftype Foo
        def initialize
          @a = 2
        end

        def it
          self
        end

        def a; @a; end
      end

      %Foo{}.it.a
    )

    itr.stack.last.should eq(val(2))
  end

  it "can be used as the receiver of a method" do
    itr = parse_and_interpret %q(
      deftype Foo
        def a; 2; end
        def foo; self.a; end
      end

      f = %Foo{}
      f.a
    )

    itr.stack.last.should eq(val(2))
  end

  it "works through module inclusion" do
    itr = parse_and_interpret %q(
      defmodule Foo
        def f; self.a; end
      end

      deftype Thing
        include Foo

        def a; 2; end
      end

      %Thing{}.f
    )

    itr.stack.last.should eq(val(2))
  end

  it "follows `self` as set by Call receivers" do
    itr = parse_and_interpret %q(
      deftype Foo
        def foo; :hi; end
        def foo_proxy
          self.foo
        end
      end

      %Foo{}.foo_proxy
    )

    itr.stack.last.should eq(val(:hi))
  end

  it "returns the Kernel at the root scope" do
    itr = parse_and_interpret %q(
      def foo; 2; end

      self.foo
    )

    itr.stack.last.should eq(val(2))
  end

  it "as an argument, is not affected by Call receivers" do
    itr = interpret_with_mocked_output %q(
      deftype Foo
        def put_self
          IO.puts(self)
        end

        def to_s
          "hello"
        end
      end

      %Foo{}.put_self
    )

    itr.output.to_s.should eq("hello\n")
  end
end
