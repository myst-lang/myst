require "../spec_helper.cr"

private UNARY_OPERATORS = [ "+", "-", "!"]

describe "Unary Expression" do
  {% for op in UNARY_OPERATORS %}
    it "is valid with a {{op.id}} operator before an operand" do
      assert_valid %q(
        {{op.id}} 1
      )
    end

    it "is valid with no spacing around the {{op.id}} operator" do
      assert_valid %q(
        {{op.id}}1
      )
    end

    it "is invalid with newlines after the {{op.id}} operator" do
      assert_invalid %q(
        {{op.id}}
        1
      )
    end
  {% end %}
end
