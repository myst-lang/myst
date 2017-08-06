require "../spec_helper"

private def assert_integer(source, value=nil)
  token = tokenize(source).first
  token.type.should eq(Token::Type::INTEGER)
  token.value.should eq(value) if value
end

private def assert_non_integer(source)
  tokenize(source).first.type.should_not eq(Token::Type::INTEGER)
end


describe "Integer" do
  it "is started with a numeric character" do
    assert_integer "1", value: "1"
    assert_integer "987654321", value: "987654321"
  end

  it "may contain underscore separators" do
    assert_integer "1_000_000_000", value: "1000000000"
  end

  it "must not contain a point character" do
    assert_non_integer "1.45"
  end

  it "is terminated by a point character without succeeding numeric characters" do
    assert_integer "1.to_s", value: "1"
  end

  it "allows arbitrarily large values" do
    # The value tested here is a Googol.
    assert_integer "1"+"0"*100
  end

  it "must not start with an underscore" do
    assert_non_integer "_100"
  end

  it "may end with an underscore" do
    assert_integer "100_", value: "100"
  end
end

