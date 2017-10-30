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
  distinct_types = ["nil", "true", "false", "1", "1.5", "\"hi\"", ":hi", "[]", "{}"]
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



  # Splats in a List pattern collect remaining, unmatched entries from the value.
  it_interprets_with_assignments %q([1, 2, *tail] =: [1, 2, 3, 4]), { "tail"  => val([3, 4]) }
  it_interprets_with_assignments %q([*head, 3, 4] =: [1, 2, 3, 4]), { "head"  => val([1, 2]) }
  it_interprets_with_assignments %q([1, *mid, 4]  =: [1, 2, 3, 4]), { "mid"   => val([2, 3]) }

  # Splats can also match 0 or 1 elements and will still result in a List.
  it_interprets_with_assignments %q([1, *mid, 2]  =: [1, 2]),     { "mid"   => TList.new }
  it_interprets_with_assignments %q([1, *mid, 3]  =: [1, 2, 3]),  { "mid"   => val([2]) }

  # Splats do not affect the value being collected. e.g., if a single List
  # value remains to be collected by the splat, it will be wrapped inside
  # another List, rather than being flattened into a single List.
  it_interprets_with_assignments %q([1, *list]  =: [1, [2, 3]]),  { "list"  => val([[2, 3]]) }

  # Multiple splats in a pattern are invalid
  it_does_not_interpret %q([*a, *b]       =: [1, 2]),   /splat collector/
  it_does_not_interpret %q([1, *a, 2, *b] =: [1, 2]),   /splat collector/


  # Matching a Const that refers to a TType will check the type of the value.
  it_interprets %q(List     =: [1, 2])
  it_interprets %q(Integer  =: 1)
  it_interprets %q(Nil      =: nil)
  it_interprets %q(String   =: "hello")

  # If the value is _not_ an instance of the pattern type, the match fails.
  it_does_not_interpret %q(String   =: :hello)
  it_does_not_interpret %q(Integer  =: 1.0)
  it_does_not_interpret %q(Boolean  =: nil)

  # When a Const refers to anything other than a TType, the match will act like
  # a normal value match.
  it_interprets %q(
    A = 10
    A =: 10
  )

  it_does_not_interpret %q(
    A = false
    A =: true
  ), /match/

  # Both styles of matching with Consts works through interpolation.
  it_interprets %q(<String>   =: "hello")
  it_interprets %q(
    A = 1
    <A> =: 1
  )


  # Type matching works even when the pattern is not a Const.
  it_interprets %q(
    int_type = 1.type
    <int_type> =: 5
  )
  it_does_not_interpret %q(
    float_type = 1.5.type
    <float_type> =: 1
  ),  /match/
end
