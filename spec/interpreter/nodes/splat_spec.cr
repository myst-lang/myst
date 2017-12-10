require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Splat" do
  it "calls the unary * method on the receiver" do
    itr = parse_and_interpret %q(
      deftype Foo
        def *
          [1, 2, 3]
        end
      end

      *%Foo{}
    )

    itr.stack.last.should eq(val([1, 2, 3]))
  end

  it "expects a List value as a result" do
    itr = interpret_with_mocked_output %q(
      deftype Foo
        def *
          :not_a_list
        end
      end

      f = %Foo{}
      *f
    )

    itr.errput.to_s.downcase.should match(/expected a list/)
  end

  it "can be applied to a Module" do
    itr = parse_and_interpret %q(
      defmodule Foo
        def *
          [1, 2, 3]
        end
      end

      *Foo
    )

    itr.stack.last.should eq(val([1, 2, 3]))
  end

  it "can be applied statically on a Type" do
    itr = parse_and_interpret %q(
      deftype Foo
        defstatic *
          [1, 2, 3]
        end
      end

      *Foo
    )

    itr.stack.last.should eq(val([1, 2, 3]))
  end

  describe "when used in a List literal" do
    it "concatenates the result after the existing List elements" do
      itr = parse_and_interpret %q(
        defmodule Foo
          def *
            [1, 2, 3]
          end
        end

        [*Foo, 4, 5, 6]
      )

      itr.stack.last.should eq(val([1, 2, 3, 4, 5, 6]))
    end

    it "can be used multiple times" do
      itr = parse_and_interpret %q(
        defmodule Foo
          def *
            [1, 2, 3]
          end
        end

        [*Foo, *Foo]
      )

      itr.stack.last.should eq(val([1, 2, 3, 1, 2, 3]))
    end
  end


  describe "when used as a Call argument" do
    it "concatenates the resulting List to the Call's existing arguments" do
      itr = parse_and_interpret %q(
        deftype Foo
          def *
            [1, 2, 3]
          end
        end

        def foo(a, b, c)
          :matched
        end

        foo(*%Foo{})
      )

      itr.stack.last.should eq(val(:matched))
    end
  end
end
