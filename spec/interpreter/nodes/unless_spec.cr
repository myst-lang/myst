require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Unless" do
  it_interprets %q(
    unless true
      1
    end
  ),                  [val(nil)]
  it_interprets %q(
    unless false
      1
    end
  ),                  [val(1)]
  it_interprets %q(
    unless true
      1
    else
      2
    end
  ),                  [val(2)]
  it_interprets %q(
    unless false
      1
    else
      2
    end
  ),                  [val(1)]
  it_interprets %q(
    unless true
      1
    unless true
      2
    else
      3
    end
  ),                  [val(3)]

  it_interprets %q(
    unless true
      1
    unless false
      2
    else
      3
    end
  ),                  [val(2)]

  it_interprets %q(
    unless false
      1
    unless false
      2
    else
      3
    end
  ),                  [val(1)]

  # For brevity, tests after this point will use a more compact form where
  # appropriate.
  it_interprets %q(
    unless 1 == 1;  1
    else;           2
    end
  ),                  [val(2)]

  it_interprets %q(
    unless 1 == 2;  1
    else;           2
    end
  ),                  [val(1)]

  it_interprets %q(
    unless 3 + 4;   false
    else;           true
    end
  ),                  [val(true)]
end
