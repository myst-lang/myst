require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

# This section uses a small sample of Call formats to test the general ability
# of the interpreter to evaluate them. Coverage of infix operators, native
# functions, and standard library functions will be done separately.
#
# This section of tests relies on the Integer type with `+` and `to_s` methods
# defined.
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

  # When looking up a function, the current lexical scope should be checked for
  # overrides. However, parent lexical scopes should be ignored.
  it_interprets %q(
    defmodule Foo
      def block
        nil
      end

      def foo(&block)
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
