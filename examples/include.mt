# `include` is a keyword that adds an ancestor to the current scope to be used
# for value lookups performed in that scope (variables, functions, other
# modules, etc.).
module Bar
  def bar(a, b)
    a + b
  end
end

module Nested
  module Baz
    def baz(a, b)
      a - b
    end
  end
end

module Foo
  include Bar
  include Nested.Baz
end

IO.puts(Foo.bar(1, 2)) #=> 3
IO.puts(Foo.baz(2, 1)) #=> 1


# Includes work on any scope, including the top level. The following will make
# the contents of `Nested` available without namespacing at the top level. In
# this case, that means the `Baz` module can be referenced without the need to
# prefix it with `Nested.`.
include Nested
IO.puts(Baz.baz(5, 1)) #=> 4
