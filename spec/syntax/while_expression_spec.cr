require "../spec_helper"

describe "While Expression" do
  it "is valid with a simple expression as a condition" do
    assert_valid %q(
      while true
      end
    )
  end

  it "is invalid with no condition" do
    assert_invalid %q(
      while
      end
    )
  end

  it "is invalid without a closing `end` keyword" do
    assert_invalid %q(
      while true
    )
  end

  it "is valid with a single-expression body" do
    assert_valid %q(
      while true
        1 + 1
      end
    )
  end

  it "is valid with a multi-expression body" do
    assert_valid %q(
      while true
        a = 1
        b = 1
        a + b
      end
    )
  end

  it "is valid with a complex expression as a condition" do
    assert_valid %q(
      while a && b + c || d < 5
      end
    )
  end

  it "is valid when nested inside another `while`" do
    assert_valid %q(
      while a
        while b
          while c
          end
        end
      end
    )
  end
end
