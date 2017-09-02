require "../spec_helper"

describe "When Expression" do
  it "is valid with a simple expression as a condition" do
    assert_valid %q(
      when true
      end
    )
  end

  it "is invalid with no condition" do
    assert_invalid %q(
      when
      end
    )
  end

  it "is invalid without a closing `end` keyword" do
    assert_invalid %q(
      when true
    )
  end

  it "is valid with a single-expression body" do
    assert_valid %q(
      when true
        1 + 1
      end
    )
  end

  it "is valid with a multi-expression body" do
    assert_valid %q(
      when true
        a = 1
        b = 1
        a + b
      end
    )
  end

  it "is valid with a complex expression as a condition" do
    assert_valid %q(
      when a && b + c || d < 5
      end
    )
  end

  it "is valid when nested inside another `when`" do
    assert_valid %q(
      when a
        when b
          when c
          end
        end
      end
    )
  end

  it "is valid when chained after another `when`" do
    assert_valid %q(
      when a
        1
      when b
        2
      end
    )
  end

  it "is valid when chained after an `unless` block" do
    assert_valid %q(
      unless a
        1
      when b
        2
      end
    )
  end
end
