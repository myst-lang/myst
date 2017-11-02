require "../helper.cr"

describe "Printer - BinaryOp" do
  assert_print %q(1 || 2)
  assert_print %q(1 || 2 || 3)

  assert_print %q(1 && 2)
  assert_print %q(1 && 2 && 3)

  assert_print %q(a == b && b == c)
  assert_print %q(a != nil && b != nil)
  assert_print %q(true == false || a != b)
  assert_print %q(true && true || false && false)
end
