require "../helper.cr"

describe "Printer - Expressions" do
  assert_print %Q(1\n2)
  assert_print %Q(1 + 1\n2 + 2)
end
