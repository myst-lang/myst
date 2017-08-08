require "../spec_helper.cr"

describe "List Literal" do
  it "is valid with no elements" do
    assert_valid %q(
      []
    )
  end

  it "is valid with one element" do
    assert_valid %q(
      [1]
    )
  end

  it "is valid with multiple elements" do
    assert_valid %q(
      [1, 2, 3]
    )
  end

  it "is valid with mixed expression elements" do
    assert_valid %q(
      [variable, 1, 5.6 + 3, "string", func(), postfix[expr]]
    )
  end

  it "is valid with nested list elements" do
    assert_valid %q(
      [[1, 2], [2, 3], [3, 4], [deeper, [nesting, here]]]
    )
  end

  it "can span multiple lines" do
    assert_valid %q(
      [
        1, 2,
        3, 4
      ]
    )
  end

  it "is invalid with a trailing comma" do
    assert_invalid %q(
      [1, 2, 3, ]
    )
  end

  it "is valid on the right-hand-side of an assignment" do
    assert_valid %q(
      x = [1, 2, 3]
    )
  end

  it "is valid as part of a binary expression" do
    assert_valid %q(
      list == [1, 2, 3] + [4, 5, 6]
    )
  end

  # Value interpolations are non-sensical outside of pattern-matching,
  # but are still valid in list literals.
  it "is valid with value interpolations" do
    assert_valid %q(
      [<var>, <func()>]
    )
  end
end
