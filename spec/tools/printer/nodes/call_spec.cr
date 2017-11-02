require "../helper.cr"

# Calls are complex structures that can take a number of forms.
# This spec aims to be exhaustive of all possible styles.
describe "Printer - Call" do
  # Infix
  #
  # Infix calls are the strictest structure, only allowing a single operand on
  # either side of the operator.
  assert_print %q(1 + 1)
  assert_print %q(1.0 + 1)
  assert_print %q("hello" + "again")
  assert_print %q(:hi + nil)
  assert_print %q([1, 2, 3] + [4, 5, 6])
  assert_print %q(a == b)
  assert_print %q(10 >= 5)

  # Chaining infix calls should all appear inline.
  assert_print %q(1 + 1 + 1)
  assert_print %q("a" + :hello + "c")
  assert_print %q(nil + true + false)
  assert_print %q({a: 1} + {b: 2})



  # No receiver, no arguments, no block
  #
  # These should simply be the same as a Var, just that the name had not been
  # initialized before hand (e.g., by a SimpleAssign). Consts and Underscores
  # are not included here.
  #
  # For now, calls with no arguments, but with parentheses included, will have
  # the parentheses stripped by the printer.
  assert_print %q(a)
  assert_print %q(name)
  assert_print %q(something_longer)
  assert_print %q(no_args()), %q(no_args)



  # Receiver, no arguments, no block
  #
  # With a receiver but nothing else, the formatting is just the receiver
  # followed by `.<name>`, where `<name>` is the call being made.
  assert_print %q(object.member)
  assert_print %q(1.to_s)
  assert_print %q("hello".split)
  assert_print %q([1, 2, 3].first)
  assert_print %q(a.b.c)



  # Arguments, no block
  #
  # With or without a receiver, calls with arguments must wrap them in
  # parentheses. Each argument will be comma separated. Nesting has all the
  # same rules.
  #
  # These calls can also be followed by another call.
  assert_print %q(foo(1))
  assert_print %q(foo("hello"))
  assert_print %q(foo(1, 2))
  assert_print %q(foo(a, b))
  assert_print %q(foo(a.b, b(c, d)))
  assert_print %q(foo(a == true, 5 + 6, obj.member))
  assert_print %q(foo(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12))

  assert_print %q(thing.foo(1))
  assert_print %q(thing.foo("hello"))
  assert_print %q(thing.foo(1, 2))
  assert_print %q(thing.foo(a, b))
  assert_print %q(thing.foo(a.b, b(c, d)))
  assert_print %q(thing.foo(a == true, 5 + 6, obj.member))
  assert_print %q(thing.foo(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12))

  assert_print %q(thing.foo(1, 2).bar)
  assert_print %q(thing.foo(a, b).bar)
  assert_print %q(thing.foo(a.b, b(c, d)).bar)
  assert_print %q(thing.foo(1).bar(1, 2))
  assert_print %q(thing.foo("hello").bar(1, 2))
  assert_print %q(thing.foo(a == true, 5 + 6, obj.member).bar(1, 2))
  assert_print %q(thing.foo(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12).bar(1, 2))



  # Access notation ([])
  #
  # The access notation, `[]`, is a special case. It does not include the dot,
  # and inserts the arguments between the braces, rather than after.
  #
  # Access notation does not allow blocks.
  assert_print %q("hello"[1])
  assert_print %q("hello"[1, 2])
  assert_print %q(list[100])
  assert_print %q({a: 1, b: 2}[:a])
  assert_print %q([1, 2, 3][0])
  assert_print %q([1, 2, 3][0, 1, 2, 3])
end
