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

  # Matches between different classes (other than Integer and Float), can never
  # match successfully.
  distinct_types = ["nil", "true", "false", "1", "\"hi\"", ":hi", "[]", "{}"]
  distinct_types.each_with_index do |a, i|
    distinct_types.each_with_index do |b, j|
      next if i == j
      it_does_not_interpret "#{a} =: #{b}", /match/
    end
  end

  # As with `==`, matches with Floats and Integers are successful when the
  # values are mathematically equal (e.g., the float has no decimal value).
  it_interprets %q(1    =: 1.0)
  it_interprets %q(1.0  =: 1)

  it_does_not_interpret %q(1    =: 1.1),  /match/
  it_does_not_interpret %q(1.1  =: 1),    /match/


  # Assignments at any level should either create or re-assign the variable
  # in the current scope.
  it_interprets_with_assignments  %q(a =: 1),             { "a" => val(1) }
  it_interprets_with_assignments  %q([a, b] =: [1, 2]),   { "a" => val(1), "b" => val(2) }
  it_interprets_with_assignments  %q(a =: [1, 2]),        { "a" => val([1, 2]) }
  it_interprets_with_assignments  %q({a: a} =: {a: 3}),   { "a" => val(3) }
  it_interprets_with_assignments  %q({a: [a, 2]} =: {a: [1, 2]}),   { "a" => val(1) }
  it_interprets_with_assignments  %q([a, [2, [b, 4], c]] =: [1, [2, [3, 4], 5]]),   { "a" => val(1), "b" => val(3), "c" => val(5) }
  it_interprets_with_assignments  %q(
    a = 2
    a =: 1
  ),             { "a" => val(1) }

  # Interpolations should _not_ re-assign the value of a variable. In this
  # case, the Integer and Float values will match, but `a` should still be the
  # Integer it was originally assigned as.
  it_interprets_with_assignments  %q(
    a = 2
    <a> =: 2.0
  ),             { "a" => val(2) }
end
