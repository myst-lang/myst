require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

MODULE_DEF = %q(
  defmodule Foo
    def foo
      :included
    end

    def call_bar
      bar
    end
  end
)

describe "Interpreter - Include" do
  # Modules may be included at the top level. The result should make the
  # properties and methods of the module available at the top-level scope.
  it_interprets MODULE_DEF + %q(
    include Foo

    foo
  ),        [val(:included)]

  it "returns the included module when successful" do
    itr = parse_and_interpret MODULE_DEF + %q(
      include Foo
    )

    itr.stack.pop.should eq(itr.current_scope["Foo"])
  end


  it_does_not_interpret %q(include nil)
  it_does_not_interpret %q(include true)
  it_does_not_interpret %q(include false)
  it_does_not_interpret %q(include "hello")
  it_does_not_interpret %q(include :hi)
  it_does_not_interpret %q(include [1, 2])
  it_does_not_interpret %q(include {a: 1})


  it "maintains `self` when calling methods through include" do
    itr = parse_and_interpret MODULE_DEF + %q(
      deftype Thing
        include Foo

        def bar
          :called_bar
        end
      end

      %Thing{}.call_bar
    )

    itr.stack.pop.should eq(val(:called_bar))
  end

  it "is allowed on Modules" do
    itr = parse_and_interpret MODULE_DEF + %q(
      defmodule Bar
        include Foo
      end

      Bar.foo
    )

    itr.stack.pop.should eq(val(:included))
  end

  it "includes all ancestors of the included module" do
    itr = parse_and_interpret MODULE_DEF + %q(
      defmodule Bar
        include Foo
      end

      defmodule Baz
        include Bar
      end

      Baz.foo
    )

    itr.stack.pop.should eq(val(:included))
  end
end
