require "../helper.cr"

describe "Printer - Value Interpolation" do
  assert_print %q(<nil>)
  assert_print %q(<true>)
  assert_print %q(<false>)
  assert_print %q(<1>)
  assert_print %q(<1.5>)
  assert_print %q(<"hi">)
  assert_print %q(<:hello>)
  assert_print %q(<[1, 2]>)
  assert_print %q(<[a, *b]>)
  assert_print %q(<{a: 1}>)

  assert_print %q(<a>)
  assert_print %q(<a(1, 2)>)
  assert_print %q(<a.b(1)>)
  assert_print %q(<a.b.c>)
  # TODO: revisit with blocks
  # assert_print %q(<a{ }>)
  # assert_print %q(<a do; end>)
  assert_print %q(<Thing>)
  assert_print %q(<Thing.Other>)
  assert_print %q(<A.B.C>)
  assert_print %q(<_>)
  assert_print %q(<a[0]>)
  assert_print %q(<a.b[0]>)
  assert_print %q(<[1, 2][0]>)
  assert_print %q(<{a: 1}[:a]>)
  assert_print %q(<a(1, 2)[0]>)

  # TODO: revisit with paren capturing
  # assert_print %q(<(1 + 2)>)

  assert_print %q([1, <2>, 3])
  assert_print %q([1, <a.b>, 3])
  assert_print %q(<a[0]> + 4)
end
