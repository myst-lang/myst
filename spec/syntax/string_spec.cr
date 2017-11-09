require "../spec_helper"

private def assert_token_type(source, token_type)
  token = tokenize(source).first
  token.type.should eq(token_type)
end

private def it_lexes(source, *token_types, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  it "lexes `#{source}`", file, line, end_line do
    tokens = tokenize(source)
    # An `EOF` token is always added at the end by the tokenizer, so asserting
    # that a single token was lexed means checking for 2 tokens in the stream.
    token_types.each_with_index do |expected_type, i|
      tokens[i].type.should eq(expected_type)
    end
  end
end


describe "Lexer - Simple strings" do
  it "does not include quote characters in string values" do
    tokens = tokenize(%q("hello"))
    string_token = tokens.first
    string_token.type.should eq(Token::Type::STRING)
    string_token.value.should eq("hello")
  end

  it "allows empty double quoted strings" do
    assert_token_type %q(""),   Token::Type::STRING
  end

  it "allows empty strings with whitespace" do
    assert_token_type %q("    "), Token::Type::STRING
  end

  it "allows strings with arbitrary content" do
    assert_token_type %q("hello, world"), Token::Type::STRING
  end

  it "allows literal newlines" do
    assert_token_type %q("hello,
    world"),                              Token::Type::STRING
  end

  ['"', '0', 't', 'n', '\\'].each do |escape|
    # The code tested here is `"\escape"`
    it "allows #{escape} as an escape sequence" do
      assert_token_type %Q("\\#{escape}"), Token::Type::STRING
    end
  end
end



private STR     = Token::Type::STRING
private INT     = Token::Type::INTEGER
private WS      = Token::Type::WHITESPACE
private ISTART  = Token::Type::INTERP_START
private IEND    = Token::Type::INTERP_END
private IDENT   = Token::Type::IDENT
private PLUS    = Token::Type::PLUS
private POINT   = Token::Type::POINT
private LBRACE  = Token::Type::LBRACE
private RBRACE  = Token::Type::RBRACE
private LCURLY  = Token::Type::LCURLY
private RCURLY  = Token::Type::RCURLY
private COLON   = Token::Type::COLON

describe "Lexer - Interpolated Strings" do
  # Without INTERP_START, INTERP_END is lexed as a STRING
  it_lexes %q[")>"],                STR
  # Empty interpolations
  it_lexes %q("<()>"),              ISTART, IEND, STR
  it_lexes %q("hello<()>"),         STR, ISTART, IEND, STR
  it_lexes %q("<()>, world"),       ISTART, IEND, STR
  it_lexes %q("hello<()>, world"),  STR, ISTART, IEND, STR

  # Simple expressions
  it_lexes %q("<(a)>"),             ISTART, IDENT, IEND, STR
  it_lexes %q("<(1)>"),             ISTART, INT, IEND, STR
  it_lexes %q("<("")>"),            ISTART, STR, IEND, STR

  # Complex expressions
  it_lexes %q("<([])>"),            ISTART, LBRACE, RBRACE, IEND, STR
  it_lexes %q("2 is <(1+1)>"),      STR, ISTART, INT, PLUS, INT, IEND, STR

  # Maps and brace blocks in interpolations are potentially ambiguous.
  # Syntax errors here are hard to source properly.
  it_lexes %q("<(a.b{})>"),         ISTART, IDENT, POINT, IDENT, LCURLY, RCURLY, IEND, STR
  it_lexes %q("<({})>"),            ISTART, LCURLY, RCURLY, IEND, STR
  it_lexes %q("<( { }  )>"),        ISTART, WS, LCURLY, WS, RCURLY, WS, IEND, STR
  it_lexes %q("<({a: "<(b)>"})>"),  ISTART, LCURLY, IDENT, COLON, WS, ISTART, IDENT, IEND, STR, RCURLY, IEND, STR


  # Nested interpolations
  it_lexes %q("<( "<(b)>" )>"),     ISTART, WS, ISTART, IDENT, IEND, STR, WS, IEND, STR

  # Multiple interpolations
  it_lexes %q("hello, <(first_name)> <(last_name)>"),  STR, ISTART, IDENT, IEND, STR, ISTART, IDENT, IEND, STR
  it_lexes %q("<(first_name)><(last_name)>"),          ISTART, IDENT, IEND, ISTART, IDENT, IEND, STR
  it_lexes %q("hello, <(first_name)>, or <(other)>"),  STR, ISTART, IDENT, IEND, STR, ISTART, IDENT, IEND, STR
end
