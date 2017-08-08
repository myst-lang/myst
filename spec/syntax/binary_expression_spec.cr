require "../spec_helper.cr"

private BINARY_OPERATORS = ["+", "-", "*", "/", "=", "=:", "<", "<=",
                            "==", "!=", ">=", ">", "&&", "||"]

private NON_UNARY_OPERATORS = [ "*", "/", "=", "=:", "<", "<=",
                                "==", "!=", ">=", ">", "&&", "||"]

private CHAINABLE_OPERATORS = ["*", "/", "=", "=:", "==", "!=", "&&", "||"]

describe "Binary Expression" do
  {% for op in BINARY_OPERATORS %}
    it "is valid with a {{op.id}} operator between two values" do
      assert_valid %q(
        1 {{op.id}} 1
      )
    end

    it "is invalid without a second operand after the {{op.id}} operator" do
      assert_invalid %q(
        1 {{op.id}}
      )
    end

    it "is valid with newlines around the {{op.id}} operator" do
      assert_valid %q(
        1
        {{op.id}}
        1
      )
    end

    it "is valid with no spacing around the {{op.id}} operator" do
      assert_valid %q(
        1{{op.id}}1
      )
    end

  {% end %}

  {% for op in CHAINABLE_OPERATORS %}
    it "{{op.id}} is chainable with itself" do
      assert_valid %q(
        1 {{op.id}} 1 {{op.id}} 1 {{op.id}} 1
      )
    end

    it "{{op.id}} is chainable with other binary operators" do
      assert_valid %q(
        1 {{op.id}} 1 == 2 {{op.id}} 2
      )
    end
  {% end %}

  {% for op in NON_UNARY_OPERATORS %}
    it "is invalid without a operand before the {{op.id}} operator" do
      assert_invalid %q(
        {{op.id}} 1
      )
    end
  {% end %}
end
