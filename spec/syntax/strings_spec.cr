require "../spec_helper"

private def assert_string(source, value=nil)
  token = tokenize(source).first
  token.type.should eq(Token::Type::STRING)
  token.value.should eq(value) if value
end

private def assert_non_string(source)
  tokenize(source).first.type.should_not eq(Token::Type::STRING)
end


describe "String" do
  it "is started by double quotes" do
    assert_string %q("hello")
  end

  it "does not include the quotes in its value" do
    assert_string %q("hello"), value: "hello"
  end

  it "is only terminated by a closing double quote" do
    assert_string %q("hello\n\t more words"), value: "hello\n\t more words"
  end

  it "allows escaped quote characters" do
    assert_string %q("hello \"human\""), value: %q(hello "human")
  end

  it "allows arbitrary characters in its value" do
    assert_string %q("hello+*^/--<<AhiJKX˚∆˙ß\n\t"), value: "hello+*^/--<<AhiJKX˚∆˙ß\n\t"
  end

  it "allows unicode characters in its value" do
    assert_string %q("┬─┬ノ( º _ ºノ)"), value: "┬─┬ノ( º _ ºノ)"
  end
end
