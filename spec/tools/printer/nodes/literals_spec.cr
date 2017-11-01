require "../helper.cr"

describe "Printer - Literals" do
  # Nil
  assert_print  %q(nil)

  # Booleans
  assert_print  %q(true)
  assert_print  %q(false)

  # Integers
  assert_print  %q(1)
  assert_print  %q(100)
  assert_print  %q(100)

  # Floats
  assert_print  %q(1.0)
  assert_print  %q(1.345)
  assert_print  %q(12345.67)

  # Strings
  assert_print  %q("h")
  assert_print  %q("hello")
  assert_print  %q("")


  # Symbols
  assert_print  %q(:hi)
  assert_print  %q(:with_underscore)
  assert_print  %q(:with_underscore)


  # Lists
  assert_print  %q([1, 2, 3])
  assert_print  %q([nil, nil, nil])
  assert_print  %q([nil, true, false])
  assert_print  %q([true, false, 1])
  assert_print  %q([:hello, "hi", 10.054])


  # Maps
  assert_print  %q({a: 1, b: 2})
  assert_print  %q({a: "hello", b: :hi})
  assert_print  %q({a: nil, b: false, c: 10.242, d: 3})
end
