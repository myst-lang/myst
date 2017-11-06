require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

# This section uses a small sample of Call formats to test the general ability
# of the interpreter to evaluate them. Coverage of infix operators, native
# functions, and standard library functions will mostly be done separately.
describe "Interpreter - Call" do
  it_interprets %q(1 + 1),        [val(2)]
  it_interprets %q(1 + 1 + 1),    [val(3)]

  it_interprets %q(1.to_s),       [val("1")]
  it_interprets %q((1 + 1).to_s), [val("2")]

  # Block parameters are created as functors available in the current scope. As
  # such, they can be used like any other functor.
  it_interprets %q(
    def foo(&block)
      block(1)
    end

    foo do |a|
      a + 1
    end
  ),                [val(2)]

  # Methods with modifiers act identically to regular calls
  it_interprets %q(
    def is_3?(a, b)
      a + b == 3
    end

    is_3?(2, 1)
  ),                [val(true)]

  it_interprets %q(
    def is_3!(a, b)
      a + b == 3
    end

    is_3!(2, 1)
  ),                [val(true)]

  # Assignments with Calls as targets are re-written to lookup a method with
  # a trailing `=`. The only way for a Call to be the receiver of an assignment
  # is with a receiver, so this test must be done is done with a module method.
  it_interprets %q(
    defmodule Foo
      def foo(a);  @called = :no_modifier; end
      def foo=(a); @called = :assignment;  end

      def called; @called; end
    end

    Foo.foo = 1
    Foo.called
  ),              [val(:assignment)]

  # Methods with modifiers can be used as arguments in other calls
  it_interprets %q(
    defmodule Foo
      def a?; 1; end
      def b!; 2; end
    end

    Foo.a? + Foo.b!
  ),              [val(3)]

  # Operators can be overloaded by defining a method with the operator as the
  # name on an object.
  # The match operator overload will have special semantics. These are TBD from
  # https://github.com/myst-lang/myst/issues/11.
  [
    "+", "-", "*", "/", "%",
    "<", "<=", "!=", "==", ">=", ">"
  ].each do |op|
    it_interprets %Q(
      deftype Foo
        def a; @a; end
        def initialize(a)
          @a = a
        end

        def #{op}(other : Foo)
          %Foo{@a + other.a}
        end
      end

      f1 = %Foo{1}
      f2 = %Foo{2}
      f3 = f1 #{op} f2
      f3.a
    ),              [val(3)]

    # Operators can also be defined statically to do some type algebra.
    it_interprets %Q(
      deftype Foo
        defstatic #{op}(other : Foo)
          :called_op_on_type
        end
      end

      Foo #{op} Foo
    ),              [val(:called_op_on_type)]

    # Or on modules, for whatever that might be worth... (I guess this could
    # define operators in a module that could be included? Not sure why it
    # would be done outside of an `include`, though).
    it_interprets %Q(
      defmodule Foo
        def #{op}(other)
          :called_op_on_module
        end
      end

      Foo #{op} Foo
    ),              [val(:called_op_on_module)]
  end

  # Access and access assignment can also be overloaded.
  it_interprets %q(
    deftype Foo
      def initialize
        @values = [1, 2, 3]
      end

      def [](idx : Integer)
        @values[idx]
      end

      def []=(idx : Integer, value)
        @values[idx] = value
      end

      def values; @values; end
    end

    f1 = %Foo{}
    f1[2] = 5
    f1.values
  ),                [val([1, 2, 5])]


  # When looking up a function, the current lexical scope should be checked for
  # overrides. However, parent lexical scopes should be ignored.
  it_interprets %q(
    defmodule Foo
      def block
        nil
      end

      def foo(&block)
        # As a parameter, `block` is added as an entry in the local scope,
        # superceding the `Foo.block` method defined above.
        block(1)
      end
    end

    Foo.foo do |a|
      a + 1
    end
  ),                [val(2)]


  # Functions in Modules
  it_interprets %q(
    defmodule Foo
      def bar
        :called
      end
    end

    Foo.bar
  ),                [val(:called)]
  it_interprets %q(
    defmodule Foo
      def bar(a, b)
        a + b
      end
    end

    Foo.bar(1, 2)
  ),                [val(3)]
  it_interprets %q(
    defmodule Foo
      defmodule Bar
        def baz
          :nested
        end
      end
    end

    Foo.Bar.baz
  ),                [val(:nested)]

  # Static functions in Types
  it_interprets %q(
    deftype Foo
      defstatic bar
        :called
      end
    end

    Foo.bar
  ),                [val(:called)]
  it_interprets %q(
    deftype Foo
      defstatic bar(a, b)
        a + b
      end
    end

    Foo.bar(1, 2)
  ),                [val(3)]
  it_interprets %q(
    deftype Foo
      deftype Bar
        defstatic baz
          :nested
        end
      end
    end

    Foo.Bar.baz
  ),                [val(:nested)]


  # Functions have unique scopes. Assignment to a Var inside of a scope should
  # create a new entry rather than assigning to the existing entry in a parent.
  # TODO: revisit this spec when closures are properly implemented
  it_interprets_with_assignments %q(
    a = 1
    def foo; a = 2; end
    foo
  ),              { "a" => val(1) }

  # However, reads from a variable that does not yet exist in the current scope
  # should check parent scopes.
  it_interprets %q(
    a = 1
    def foo; a; end
    foo
  ),              [val(1)]
end
