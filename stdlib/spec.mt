require "./spec/errors.mt"
require "./spec/single_spec.mt"
require "./spec/describe_container.mt"
require "./assert.mt"
require "./colored.mt"

include Spec

#doc Spec
#| A simple library for writing specs around Myst code. Specs are written using
#| `it`, providing either a name, a code block to test, or both. Multiple `it`s
#| can be organized under a `describe` block for better visual clarity.
#|
#| When running an `it` spec, it is considered a "pass" so long as the given
#| block runs without raising an unhandled error. If an error does propogate
#| to outside of the `it` block, the spec is considered "failed".
#|
#| Specs are often best written using an assertion library (such as the
#| standard library's `Assert` module) to remove boilerplate and better express
#| the intention of each spec.
#|
#| By default, a passing spec will output a green `.` to the terminal, while a
#| failing spec will output a red `F`. For now, execution will immediately halt
#| on the first assertion failure, and the program will exit with a non-zero
#| status code.
defmodule Spec
  describe_stack = []

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
