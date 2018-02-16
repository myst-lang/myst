require "./spec/dsl.mt"
require "./spec/errors.mt"
require "./spec/single_spec.mt"
require "./spec/describe_container.mt"
require "./colored.mt"

include Spec

# Spec
#
# A simple library for writing specs around Myst code. Specs are written using
# `it`, providing either a name, a code block to test, or both. Multiple `it`s
# can be organized under a `describe` block for better visual clarity.
#
# The Spec library operates primarily through `assert`. Each spec can make
# multiple calls to `assert`, with an argument that is expected to be truthy.
# If the given argument is not truthy, the spec is considered failed, and the
# suite will not pass.
#
# By default, a passing assertion will output a green `.` to the terminal,
# while a failing assertion will output a red `F`. For now, execution will
# immediately halt on the first assertion failure, and the program will exit
# with a non-zero status code.
#
#
# Note: A lot of this implementation exists as a workaround for not being able
# to save references to functors into variables (they just get treated as
# Calls). This should be addressed before too long, since it's a fairly common
# use case, but a basic Spec library does not require it.
defmodule Spec
  describe_stack = []
  include DSL

  def it(name, &block)
    spec = %SingleSpec{name}
    spec.run{ block() }
  end

  def it(&block)
    it("unnamed") { block() }
  end

  def it(name)
    it(name) { }
  end


  def describe(name, &block)
    describe_stack.push(%DescribeContainer{name})
    block()
    describe_stack.pop
  end
end
