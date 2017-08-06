require "../spec_helper"

private def assert_symbol(source, value=nil)
  token = tokenize(source).first
  token.type.should eq(Token::Type::SYMBOL)
  token.value.should eq(value) if value
end

private def assert_non_symbol(source)
  tokenize(source).first.type.should_not eq(Token::Type::SYMBOL)
end


describe "Symbol" do
  it "is started by a colon" do
    assert_symbol ":hello"
  end

  it "does not include the colon in its value" do
    assert_symbol ":hello", value: "hello"
  end

  it "is terminated by whitespace" do
    assert_symbol ":hello world", value: "hello"
  end

  it "is terminated by operators" do
    assert_symbol ":hello==:world", value: "hello"
  end

  it "is terminated by a colon suffix" do
    assert_symbol ":hello:", value: "hello"
  end

  describe "with quote wrapping" do
    it "can include whitespace characters" do
      assert_symbol %q(:"hello world"), value: "hello world"
    end

    it "can include various punctuation" do
      assert_symbol %q(:"%hello, world!\n<%$"), value: "%hello, world!\n<%$"
    end
  end
end
