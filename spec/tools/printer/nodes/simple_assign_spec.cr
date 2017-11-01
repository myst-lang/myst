require "../helper.cr"

describe "Printer - SimpleAssign" do
  assert_print  %q(a = 1)
  assert_print  %q(longer_name = nil)
  assert_print  %q(mIxEdCaSiNg = "correct")
  assert_print  %q(numeric1234 = something_else = 2)
  assert_print  %q(numeric1234 = A = 3)
  assert_print  %q(numeric1234 = CONSTANT)

  assert_print  %q(A = B)
  assert_print  %q(LongerName = 100)
  assert_print  %q(SCREAMING_CASE = [1, 2, 3])
  assert_print  %q(MiXeDcAsInG = Sure)

  assert_print  %q(_a = _b)
  assert_print  %q(_longer_name = _another_one)
  assert_print  %q(_mIxEdCaSiNg = _numeric1234)

  assert_print  %q(@a = false)
  assert_print  %q(@long_name = false)
  assert_print  %q(@mIxEdCaSiNg = false)
  assert_print  %q(@numeric123 = false)


  # TODO: Add assignments with Calls.
end
