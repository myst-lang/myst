require "../spec_helper"

describe "Until Expression" do
  it "is valid with a simple expression as a condition" do
    assert_valid %q(
      until true
      end
    )
  end

  it "is invalid with no condition" do
    assert_invalid %q(
      until
      end
    )
  end

  it "is invalid without a closing `end` keyword" do
    assert_invalid %q(
      until true
    )
  end

  it "is valid with a single-expression body" do
    assert_valid %q(
      until true
        1 + 1
      end
    )
  end

  it "is valid with a multi-expression body" do
    assert_valid %q(
      until true
        a = 1
        b = 1
        a + b
      end
    )
  end

  it "is valid with a complex expression as a condition" do
    assert_valid %q(
      until a && b + c || d < 5
      end
    )
  end

  it "is valid when nested inside another `until`" do
    assert_valid %q(
      until a
        until b
          until c
          end
        end
      end
    )
  end
end
