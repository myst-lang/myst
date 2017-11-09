require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - InterpolatedStringLiterals" do
  # Empty interpolations should be removed from the resulting string.
  it_interprets %q("<()>"),                       [val("")]
  it_interprets %q("<()>"),                       [val("")]
  it_interprets %q("hello<()>"),                  [val("hello")]
  it_interprets %q("<()>, world"),                [val(", world")]
  it_interprets %q("hello<()>, world"),           [val("hello, world")]
  it_interprets %q("<()>hello<()>, world<()>!"),  [val("hello, world!")]

  # Simple expressions
  it_interprets %q("<(nil)>"),                    [val("")]
  it_interprets %q("<(true)>"),                   [val("true")]
  it_interprets %q("<(false)>"),                  [val("false")]
  it_interprets %q("<(1)>"),                      [val("1")]
  it_interprets %q("<(1.0)>"),                    [val("1.0")]
  it_interprets %q("<("hi")>"),                   [val("hi")]
  it_interprets %q("<("")>"),                     [val("")]
  it_interprets %q("<(:hi)>"),                    [val("hi")]
  it_interprets %q("<("<(2)>")>"),                [val("2")]
  it_interprets %q(a = 1; "<(a)>"),               [val("1")]

  # Complex expressions
  it_interprets %q("2 is <(1 + 1)>"),             [val("2 is 2")]

  # Multiple interpolations
  it_interprets %q("hello, <("john")> <("smith")>!"),  [val("hello, john smith!")]
end
