require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Raise" do
  # raise accepts any value as an argument.
  describe "with arbitrary arguments" do
    it_raises %q(raise nil),    ""
    it_raises %q(raise false),  "false"
    it_raises %q(raise true),   "true"
    it_raises %q(raise 1),      "1"
    it_raises %q(raise 1.0),    "1.0"
    it_raises %q(raise "err"),  "err"
    it_raises %q(raise :err),   "err"
    # As they are not defined natively, stubbed `to_s` implementations are
    # given for List and Map to ensure a consistent result here.
    it_raises %q(
      deftype List
        def to_s
          "a list"
        end
      end

      raise []
    ),                          "a list"
    it_raises %q(
      deftype Map
        def to_s
          "a map"
        end
      end

      raise {}
    ),                          "a map"
    it_raises %q(
      a = 1
      b = 2
      raise a + b
    ),                          "3"
    it_raises %q(
      deftype SomeException
        def to_s
          "some exception"
        end
      end

      raise %SomeException{}
    ),                          "some exception"
    it_raises %q(
      deftype ClassException
        defstatic to_s
          "class exception"
        end
      end

      raise ClassException
    ),                          "class exception"
    it_raises %q(
      defmodule ModuleException
        def to_s
          "module exception"
        end
      end

      raise ModuleException
    ),                          "module exception"
  end



  it "immediately stops execution of the current block" do
    itr = interpret_with_mocked_output %q(
      a = 1
      raise "an error"
      a = 2
    )

    itr.current_scope["a"].should eq(val(1))
  end


  describe "within a Def" do
    it "stops execution of the def body" do
      itr = interpret_with_mocked_output %q(
        x = 1
        def foo
          raise "an error"
          x = 2
        end
        foo
      )

      itr.current_scope["x"].should eq(val(1))
    end

    it "propogates the error through Calls" do
      itr = interpret_with_mocked_output %q(
        x = 1

        def foo
          raise "an error"
        end
        foo

        x = 3
      )

      itr.current_scope["x"].should eq(val(1))
    end
  end
end
