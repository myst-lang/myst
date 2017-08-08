require "../spec_helper.cr"

describe "Map Literal" do
  it "is valid with no elements" do
    assert_valid %q(
      {}
    )
  end

  it "is valid with one element" do
    assert_valid %q(
      {a: 1}
    )
  end

  it "is valid with multiple elements" do
    assert_valid %q(
      {a: 1, b: 2, c: 3}
    )
  end

  it "is valid with mixed expression elements" do
    assert_valid %q(
      {a: 1, b: variable, c: 4.2, func: call(), access: obj.member[1]}
    )
  end

  it "is valid with nested map elements" do
    assert_valid %q(
      {nested: {map: true}}
    )
  end

  it "can span multiple lines" do
    assert_valid %q(
      {
        first: 1,
        second: 2
      }
    )
  end

  it "is invalid with a trailing comma" do
    assert_invalid %q(
      {a: 1, b: 2,}
    )
  end

  it "is valid on the right-hand-side of an assignment" do
    assert_valid %q(
      x = {a: 1, b: 2}
    )
  end

  it "is valid as part of a binary expression" do
    assert_valid %q(
      map == {a: 1} + {b: 2}
    )
  end


  describe "interpolations" do
    it "is valid with all literal types for interpolation" do
      assert_valid %q(
        {
          <100>: :integer,
          <1.0>: :float,
          <"string">: :string,
          <:symbol>: :symbol,
          <[1, 2]>: :list,
          <{a: 1}>: :map,
          <true>: :true,
          <false>: :false,
          <nil>: :nil
        }
      )
    end

    it "is valid with postfix expressions for interpolation" do
      assert_valid %q(
        {
          <object.member>: :member,
          <list[index]>: :list,
          <func(a, b)>: :function_call
        }
      )
    end

    it "is invalid with direct binary expressions for interpolation" do
      assert_invalid %q(
        {
          <1 + 1>: false
        }
      )
    end

    it "is valid with parentheses surrounding arbitrary expressions" do
      assert_valid %q(
        {
          <(1 + 1)>: true,
          <(a == b)>: true,
          <(3 >= 1)>: true
        }
      )
    end

    it "is invalid with no expression for interpolation" do
      assert_invalid %q(
        {
          <>: false
        }
      )
    end

    # Value interpolations are non-sensical outside of pattern-matching,
    # but are still valid in list literals.
    it "is valid with value interpolations" do
      assert_valid %q(
        {a: <var>, b: <func()>}
      )
    end
  end
end
