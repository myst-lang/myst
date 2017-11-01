require "../helper.cr"

describe "Printer - References" do
  # Var
  assert_print  v("a"),                 %q(a)
  assert_print  v("longer_name"),       %q(longer_name)
  assert_print  v("mIxEdCaSiNg"),       %q(mIxEdCaSiNg)
  assert_print  v("numeric1234"),       %q(numeric1234)

  # Const
  assert_print  c("A"),                 %q(A)
  assert_print  c("LongerName"),        %q(LongerName)
  assert_print  c("SCREAMING_CASE"),    %q(SCREAMING_CASE)
  assert_print  c("MiXeDcAsInG"),       %q(MiXeDcAsInG)

  # Underscore
  assert_print  u("_a"),                %q(_a)
  assert_print  u("_longer_name"),      %q(_longer_name)
  assert_print  u("_mIxEdCaSiNg"),      %q(_mIxEdCaSiNg)
  assert_print  u("_numeric1234"),      %q(_numeric1234)
  assert_print  u("_A"),                %q(_A)
  assert_print  u("_LongerName"),       %q(_LongerName)
  assert_print  u("_SCREAMING_CASE"),   %q(_SCREAMING_CASE)
  assert_print  u("_MiXeDcAsInG"),      %q(_MiXeDcAsInG)

  # IVar
  # @[a-z][_a-zA-Z0-9]*
  assert_print  iv("a"),               %q(@a)
  assert_print  iv("long_name"),       %q(@long_name)
  assert_print  iv("mIxEdCaSiNg"),     %q(@mIxEdCaSiNg)
  assert_print  iv("numeric123"),      %q(@numeric123)
end
