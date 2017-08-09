require "../spec_helper"

describe "Unless Expression" do
  it "is valid with a single expression as a condition" do
    assert_valid %q(
      unless true
      end
    )
  end

  it "is invalid with no condition" do
    assert_invalid %q(
      unless
      end
    )
  end

  it "is invalid without a closing `end` keyword" do
    assert_invalid %q(
      unless false
    )
  end

  it "is valid with a single-expression body" do
    assert_valid %q(
      unless true
        1 + 1
      end
    )
  end

  it "is valid with a multi-expression body" do
    assert_valid %q(
      unless true
        a = 1
        b = 1
        a + b
      end
    )
  end

  it "is valid with a complex expression as a condition" do
    assert_valid %q(
      unless a && b + c || d < 5
      end
    )
  end

  it "is valid when nested inside another `unless`" do
    assert_valid %q(
      unless a
        unless b
          unless c
          end
        end
      end
    )
  end
end
