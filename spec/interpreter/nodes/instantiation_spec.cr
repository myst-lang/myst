require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"


DEFS = %q(
  deftype Foo
    defstatic bar
      :static_method
    end

    def foo
      :instance_method
    end

    defstatic baz
      :static_baz
    end

    def baz
      :instance_baz
    end
  end
)

private def interpret_with_defs(source)
  parse_and_interpret(DEFS + source)
end


describe "Interpreter - Instantiation" do
  it do
    itr = interpret_with_defs %q(f = %Foo{})
    inst = itr.stack.pop.as(TInstance)
    foo_type = itr.current_scope["Foo"]
    inst.type.should eq(foo_type)
  end

  it do
    itr = interpret_with_defs %q(
      f = %Foo{}
      f.foo
    )
    result = itr.stack.pop
    result.should eq(val(:instance_method))
  end

  it "cannot access static methods through the instance" do
    # bar is a static method on Foo, so `f.bar` should not resolve.
    expect_raises do
      itr = interpret_with_defs %q(
        f = %Foo{}
        f.bar
      )
    end
  end

  it "resolves to instance methods, not static methods" do
    itr = interpret_with_defs %q(
      f = %Foo{}
      f.baz
    )
    result = itr.stack.pop
    result.should eq(val(:instance_baz))
  end

  it "has access to the type through `.type`" do
    itr = interpret_with_defs %q(
      f = %Foo{}
      f.type
    )
    result = itr.stack.pop.as(TType)
    foo_type = itr.current_scope["Foo"]
    result.should eq(foo_type)
  end

  it do
    itr = interpret_with_defs %q(
      f = %Foo{}
      f.type.baz
    )
    result = itr.stack.pop
    result.should eq(val(:static_baz))
  end

  # Instantiations must resolve the type as a TType. Any other value is invalid.
  # Because of interpolations, this cannot be asserted by the parser.
  it_does_not_interpret %q(%<nil>{})
  it_does_not_interpret %q(%<false>{})
  it_does_not_interpret %q(%<1>{})
  it_does_not_interpret %q(%<"hello">{})
  it_does_not_interpret %q(%<[]>{})
  it_does_not_interpret %q(%<{}>{})

  it "allows interpolations of type values" do
    itr = interpret_with_defs %q(
      f = %<Foo>{}
      f.baz
    )
    result = itr.stack.pop
    result.should eq(val(:instance_baz))
  end

  it "allows interpolations of type values through other variables" do
    itr = interpret_with_defs %q(
      type = Foo
      f = %<type>{}
      f.baz
    )
    result = itr.stack.pop
    result.should eq(val(:instance_baz))
  end
end
