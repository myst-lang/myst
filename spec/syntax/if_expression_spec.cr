require "../spec_helper"

describe "If Expression" do
  it "is valid with a simple expression as a condition" do
    assert_valid %q(
      if true
      end
    )
  end

  it "is invalid with no condition" do
    assert_invalid %q(
      if
      end
    )
  end

  it "is invalid without a closing `end` keyword" do
    assert_invalid %q(
      if true
    )
  end

  it "is valid with a single-expression body" do
    assert_valid %q(
      if true
        1 + 1
      end
    )
  end

  it "is valid with a multi-expression body" do
    assert_valid %q(
      if true
        a = 1
        b = 1
        a + b
      end
    )
  end

  it "is valid with a complex expression as a condition" do
    assert_valid %q(
      if a && b + c || d < 5
      end
    )
  end

  it "is valid when nested inside another `if`" do
    assert_valid %q(
      if a
        if b
          if c
          end
        end
      end
    )
  end
end
