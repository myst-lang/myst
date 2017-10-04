require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - When" do
  # Whens are used to conditionally execute a block of code. When the condition
  # is truthy, the block will be evaluated. If it is falsey, the block will not
  # be evaluated.
  it_interprets %q(
    when true
      1
    end
  ),                  [val(1)]

  # If the condition is falsey and no alternative is provided, return `nil`.
  it_interprets %q(
    when false
      1
    end
  ),                  [val(nil)]

  # When an alternative is given and the condition is truthy, do not evaluate
  # the alternative
  it_interprets %q(
    when true
      1
    else
      2
    end
  ),                  [val(1)]

  # When the condition is falsey, evaluate the alternative.
  it_interprets %q(
    when false
      1
    else
      2
    end
  ),                  [val(2)]


  # In a chain, stop evaluation after the first truthy condition
  it_interprets %q(
    when true
      1
    when true
      2
    else
      3
    end
  ),                  [val(1)]

  it_interprets %q(
    when false
      1
    when true
      2
    else
      3
    end
  ),                  [val(2)]

  it_interprets %q(
    when false
      1
    when false
      2
    else
      3
    end
  ),                  [val(3)]

  # For brevity, tests after this point will use a more compact form where
  # appropriate.
  it_interprets %q(
    when 1 == 1;  1
    else;         2
    end
  ),                  [val(1)]

  it_interprets %q(
    when 1 == 2;  1
    else;         2
    end
  ),                  [val(2)]

  it_interprets %q(
    when 3 + 4;   false
    else;         true
    end
  ),                  [val(false)]
end
