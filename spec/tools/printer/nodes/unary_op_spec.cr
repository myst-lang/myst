require "../helper.cr"

# Unary expressions are an operator followed by any valid postfix expression.
describe "Printer - UnaryOps" do
  { :! => Not, :- => Negation, :* => Splat }.each do |op, type|
    assert_print %Q(#{op}nil)
    assert_print %Q(#{op}false)
    assert_print %Q(#{op}"hello")
    assert_print %Q(#{op}[1, 2])
    assert_print %Q(#{op}{a: 2})
    assert_print %Q(#{op}:hi)
    assert_print %Q(#{op}<1.5>)
    assert_print %Q(#{op}<other>)
    assert_print %Q(#{op}a)
    # TODO: revisit with paren capturing
    # assert_print %Q(#{op}(1 + 2))
    assert_print %Q(#{op}a.b)
    assert_print %Q(#{op}Thing.b)

    # Unary operators can be chained any number of times.
    assert_print %Q(#{op}#{op}a)
    assert_print %Q(#{op}#{op}#{op}a)

    # Unary operations are more precedent than binary operations
    assert_print %Q(#{op}1 + 2)
    assert_print %Q(1 + #{op}2)

    # Unary operations can be used anywherea primary expression is expected.
    assert_print %Q([1, #{op}a])
  end

  # Unary operators can also be mixed when chaining.
  assert_print %Q(!*-a)
  assert_print %Q(-*!100)
  assert_print %Q(-!*[1, 2])

  # Unary operators have a higher precedence than any binary operation.
  assert_print %Q(-1 + -2)
  assert_print %Q(!1 || !2)
  assert_print %Q(-1 == -2)
  assert_print %Q(a = -1)
end
