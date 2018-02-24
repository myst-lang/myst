require "../spec_helper.cr"
require "../support/nodes.cr"
require "../support/interpret.cr"

# Tests for invocations and clause resolution rely on multiple clauses already
# being defined in the Interpreter. These constants act as preludes that can be
# loaded to ensure a consistent setup for each test.
FOO_DEFS = %q(
  def foo
    :no_args
  end

  def foo(1)
    :one_literal
  end

  def foo(nil)
    :nil_literal
  end

  def foo(a)
    :one_arg
  end

  def foo(a, b)
    :two_args
  end

  def foo(a, &block)
    :one_arg_with_block
  end

  def foo(&block)
    :block
  end

  def foo(1, 2, *rest)
    :trailing_splat
  end

  def foo(*head, 3, 4)
    :leading_splat
  end

  def foo(1, *mid, 4)
    :middle_splat
  end

  def foo(*all)
    :splat_all
  end
)

MODULE_DEFS = %q(
  defmodule Foo
    def foo(a)
      :one_arg
    end

    def bar
      :bar
    end
  end

  defmodule Foo
    def foo(a, b)
      :two_args
    end
  end
)

TYPE_DEFS = %q(
  deftype Foo
    defstatic foo
      :static_foo
    end

    def foo
      :instance_foo
    end
  end
)


private def it_invokes(prelude, call, expected, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  itr = parse_and_interpret(prelude)
  # Running the prelude will leave the last definition on the stack. For
  # clarity in the tests, the stack is cleared of any existing values before
  # making any assertions.
  itr.stack.clear
  it_interprets(call, [expected] of MTValue, itr, file: file, line: line, end_line: end_line)
end

describe "Interpreter - Invocation" do
  it_invokes FOO_DEFS, "foo", val(:no_args)

  it_invokes FOO_DEFS, "foo(1)",      val(:one_literal)
  it_invokes FOO_DEFS, "foo(nil)",    val(:nil_literal)
  it_invokes FOO_DEFS, "foo(2)",      val(:one_arg)
  it_invokes FOO_DEFS, "foo(1, 2)",   val(:two_args)
  it_invokes FOO_DEFS, "foo { }",     val(:block)
  it_invokes FOO_DEFS, "foo(1) { }",  val(:one_arg_with_block)
  it_invokes FOO_DEFS, "foo(2) { }",  val(:one_arg_with_block)
  # In this case, multiple clauses match this call, but because the clause
  # with the trailing splat appears first, it is selected.
  it_invokes FOO_DEFS, "foo(1, 2, 3, 4)",         val(:trailing_splat)
  it_invokes FOO_DEFS, "foo(nil, nil, 3, 4)",     val(:leading_splat)
  it_invokes FOO_DEFS, "foo(1, nil, nil, 4)",     val(:middle_splat)
  it_invokes FOO_DEFS, "foo(nil, nil, nil, nil)", val(:splat_all)


  it_invokes MODULE_DEFS, "Foo.foo(1)",     val(:one_arg)
  it_invokes MODULE_DEFS, "Foo.foo(1, 2)",  val(:two_args)
  it_invokes MODULE_DEFS, "Foo.bar",        val(:bar)

  it_invokes TYPE_DEFS, "Foo.foo",    val(:static_foo)
  it_invokes TYPE_DEFS, "%Foo{}.foo", val(:instance_foo)


  it "restores the value of `self` after executing with a receiver" do
    itr = Interpreter.new
    original_self = itr.current_self

    parse_and_interpret %q(
      "hello, world".size
    ), interpreter: itr

    itr.current_self.should eq(original_self)
    itr.self_stack.size.should eq(1)
  end

  it "restores the value of `self` after executing a closure" do
    itr = Interpreter.new
    original_self = itr.current_self

    parse_and_interpret %q(
      @sum = 0
      [1, 2, 3].each{ |e| @sum += e }
    ), interpreter: itr

    itr.self_stack.size.should eq(1)
    itr.current_self.should eq(original_self)
  end


  it "pops all scope overrides after an explicit return (see #155)" do
    itr = Interpreter.new
    original_self = itr.current_self

    # Old behavior:
    # The explicit return in `bar` would cause a call to it to skip popping
    # the scope override for it from the `scope_stack`. So, when execution of
    # `foo` is resumed after calling `bar`, the lookup of `b` fails, as the
    # `current_scope` is still the local scope override of `bar`, which has no
    # entry with the name `b`.
    parse_and_interpret! %q(
      def bar(a)
        return a
      end

      def foo(a, b)
        bar(a)
        b
      end

      foo(1, 3)
    ), interpreter: itr

    itr.self_stack.size.should eq(1)
    itr.current_self.should eq(original_self)
  end
end
