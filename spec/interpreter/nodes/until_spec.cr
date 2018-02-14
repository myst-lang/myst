require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Until" do
  # `until` repeatedly executes its body as long as its condition is falsey.
  it_interprets %q(
    a = 1
    until a >= 3
      a += 1
    end

    a
  ),                  [val(3)]

  # If the condition is immediately truthy, the body is never run.
  it_interprets %q(
    a = 1
    until a >= 1
      a += 1
    end

    a
  ),                  [val(1)]

  # By default, `until` returns `nil`.
  it_interprets %q(
    a = 1
    until a != 1
      a = 2
    end
  ),                  [val(nil)]

  # Looping can be stopped early by using `break`.
  it_interprets %q(
    x = 0
    until x >= 5
      when x == 2
        break
      end
      x += 1
    end

    x
  ),                  [val(2)]

  # Using `break` with a value sets the return value of the `until`.
  it_interprets %q(
    x = 0
    until x >= 5
      when x == 2
        break x
      end
      x += 1
    end
  ),                  [val(2)]
end
