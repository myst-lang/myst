require "../spec_helper"

private def assert_token_type(source, token_type)
  token = tokenize(source).first
  token.type.should eq(token_type)
end


describe "Tokenizer" do
  keywords = {
    "require" => Token::Type::REQUIRE,
    "include" => Token::Type::INCLUDE,
    "module"  => Token::Type::MODULE,
    "def"     => Token::Type::DEF,
    "do"      => Token::Type::DO,
    "unless"  => Token::Type::UNLESS,
    "else"    => Token::Type::ELSE,
    "while"   => Token::Type::WHILE,
    "until"   => Token::Type::UNTIL,
    "when"    => Token::Type::WHEN,
    "end"     => Token::Type::END,
    "true"    => Token::Type::TRUE,
    "false"   => Token::Type::FALSE,
    "nil"     => Token::Type::NIL
  }

  it "lexes all keywords appropriately" do
    keywords.each do |kw, token_type|
      assert_token_type kw, token_type
    end
  end

  it "only matches keywords in lowercase" do
    keywords.keys.each do |kw|
      assert_token_type kw.upcase, Token::Type::CONST
    end
  end

  it "lexes keywords with lower precedence than identifiers" do
    assert_token_type "if_true", Token::Type::IDENT
    assert_token_type "modulef", Token::Type::IDENT
  end
end
