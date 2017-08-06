require "../spec_helper"

private def assert_float(source, value=nil)
  token = tokenize(source).first
  token.type.should eq(Token::Type::FLOAT)
  token.value.should eq(value) if value
end

private def assert_non_float(source)
  tokenize(source).first.type.should_not eq(Token::Type::FLOAT)
end


describe "Float" do
  it "must contain a decimal character" do
    assert_float "1.0", value: "1.0"
    assert_non_float "1"
  end

  it "must contain numeric characters before the radix" do
    assert_non_float ".5"
    assert_float "0.5"
  end

  it "must contain numeric characters after the radix" do
    assert_non_float "1."
    assert_float "0.0"
  end

  it "may contain underscore separators anywhere" do
    assert_float "1_000_000.123_456_789", value: "1000000.123456789"
  end

  it "is terminated by a second radix" do
    assert_float "1.0.to_s", value: "1.0"
  end

  it "must not contain non-numeric characters" do
    assert_non_float "1a2b.000"
  end
end

