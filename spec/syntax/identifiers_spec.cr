require "../spec_helper"

private def assert_identifier(source, value=nil)
  token = tokenize(source).first
  token.type.should eq(Token::Type::IDENT)
  token.value.should eq(value) if value
end

private def assert_non_identifier(source)
  tokenize(source).first.type.should_not eq(Token::Type::IDENT)
end


describe "Identifier" do
  it "can be single characters" do
    assert_identifier "a"
    assert_identifier "b"
    assert_identifier "x"
    assert_identifier "z"
  end

  it "can contain multiple characters" do
    assert_identifier "abc"
    assert_identifier "xyz"
  end

  it "can mix alphanumeric characters" do
    assert_identifier "a1"
    assert_identifier "b3b3"
    assert_identifier "aksjh414asf"
  end

  it "cannot start with a numeric character" do
    assert_non_identifier "1"
    assert_non_identifier "32abc"
    assert_non_identifier "5124xyz"
  end

  it "can be terminated with whitespace" do
    assert_identifier "a bfs", value: "a"
    assert_identifier "a\nbfs", value: "a"
  end

  it "can be terminated by punctuation characters" do
    assert_identifier "abc.xyz", value: "abc"
    assert_identifier "abc,xyz", value: "abc"
    assert_identifier "abc|xyz", value: "abc"
    assert_identifier "abc)xyz", value: "abc"
    assert_identifier "abc>xyz", value: "abc"
    assert_identifier "abc!=xyz", value: "abc"
  end

  it "has lower precedence than String" do
    assert_non_identifier %q("possible_identifier")
  end

  it "can contain underscores anywhere" do
    assert_identifier "ab_124___"
    assert_identifier "__ab____fas_q3_fas"
  end

  it "can be arbitrarily long" do
    assert_identifier "adfkhgk4hg__14afoih"*30
  end
end
