require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

EXT_MODULE_DEF = %q(
  defmodule Foo
    def foo
      :extended
    end

    def call_bar
      bar
    end
  end
)

TYPE_DEF = %q(
	deftype Baz
    extend Foo

		def bar
			"bar called"
		end

	end
)

describe "Interpreter - Extend" do
  # Modules may add static properties and methods to Types.
  it_interprets EXT_MODULE_DEF + TYPE_DEF + %q(
    Baz.foo
  ),        [val(:extended)]

  it_does_not_interpret %q(extend nil)
  it_does_not_interpret %q(extend true)
  it_does_not_interpret %q(extend false)
  it_does_not_interpret %q(extend "hello")
  it_does_not_interpret %q(extend :hi)
  it_does_not_interpret %q(extend [1, 2])
  it_does_not_interpret %q(extend {a: 1})

  it "extends all ancestors of the extended module" do
    itr = parse_and_interpret EXT_MODULE_DEF + %q(
      defmodule JuniorFoo
        include Foo
      end

      defmodule FooTheThird
        include JuniorFoo
      end

      deftype Thing
        extend FooTheThird
      end

      Thing.foo
    )


    itr.stack.pop.should eq(val(:extended))
  end

  it "does not add properties or methods to type instances" do
    itr = interpret_with_mocked_output EXT_MODULE_DEF + %q(
      deftype Bar
        extend Foo
      end

      %Bar{}.foo
    )

    itr.errput.to_s.downcase.should match(/no variable or method `foo`/)
  end

  it_does_not_interpret EXT_MODULE_DEF + %q(defmodule Baz; extend Foo; end)
end
