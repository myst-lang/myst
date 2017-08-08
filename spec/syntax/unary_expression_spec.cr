require "../spec_helper.cr"

private UNARY_OPERATORS = [ "+", "-", "!"]

describe "Unary Expression" do
  {% for op in UNARY_OPERATORS %}
    it "{{op.id}} is valid before an operand" do
      assert_valid %q(
        {{op.id}} 1
      )
    end

    it "{{op.id}} is valid with no spacing around the operator" do
      assert_valid %q(
        {{op.id}}1
      )
    end

    it "{{op.id}} is invalid with newlines after the operator" do
      assert_invalid %q(
        {{op.id}}
        1
      )
    end

    it "{{op.id}} is chainable with itself" do
      assert_valid %q(
        {{op.id}}{{op.id}}{{op.id}}1
      )
    end

    it "{{op.id}} is chainable with other unary operators" do
      assert_valid %q(
        {{op.id}}!+-1
      )
    end

    it "{{op.id}} is valid within a binary expression" do
      assert_valid %q(
        {{op.id}}a == {{op.id}}b + {{op.id}}c
      )
    end
  {% end %}
end
