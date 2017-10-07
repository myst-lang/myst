require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - MatchAssign" do
  # Assignments should leave the assigned value on the stack
  it_interprets %q(a =: 1),           [val(1)]
  it_interprets %q(a =: b =: {}),     [TMap.new]
  it_interprets %q(_forget =: 1.0),   [val(1.0)]
  # Consts can't be re-assigned, so in matches they are treated as if they are
  # the interpolation of the value they contain.
  it_interprets %q(THING = nil; THING =: nil),     [val(nil)]

  # A match with the same object should always succeed.
  it_interprets %q(nil    =: nil)
  it_interprets %q(true   =: true)
  it_interprets %q(false  =: false)
  it_interprets %q(1      =: 1)
  it_interprets %q(1.0    =: 1.0)
  it_interprets %q("hi"   =: "hi")
  it_interprets %q(:hello =: :hello)
  it_interprets %q([]     =: [])
  it_interprets %q([1, 2] =: [1, 2])
  it_interprets %q({}     =: {})
  it_interprets %q({a: 1} =: {a: 1})

  # The remaining matches should all fail.
  # it_does_not_interpret %q(nil    =: false), /match/
  # it_does_not_interpret %q(nil    =: false), /match/
end
