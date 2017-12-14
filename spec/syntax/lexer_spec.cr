require "../spec_helper"

private def assert_token_type(source, token_type)
  token = tokenize(source).first
  token.type.should eq(token_type)
end

STATIC_TOKENS = {
  Token::Type::PLUS         =>  "+",
  Token::Type::MINUS        =>  "-",
  Token::Type::STAR         =>  "*",
  Token::Type::SLASH        =>  "/",
  Token::Type::EQUAL        =>  "=",
  Token::Type::NOT          =>  "!",
  Token::Type::MATCH        =>  "=:",
  Token::Type::LESS         =>  "<",
  Token::Type::LESSEQUAL    =>  "<=",
  Token::Type::EQUALEQUAL   =>  "==",
  Token::Type::NOTEQUAL     =>  "!=",
  Token::Type::GREATEREQUAL =>  ">=",
  Token::Type::GREATER      =>  ">",
  Token::Type::ANDAND       =>  "&&",
  Token::Type::OROR         =>  "||",
  Token::Type::ANDOP        =>  "&&=",
  Token::Type::OROP         =>  "||=",
  Token::Type::PLUSOP       =>  "+=",
  Token::Type::MINUSOP      =>  "-=",
  Token::Type::STAROP       =>  "*=",
  Token::Type::SLASHOP      =>  "/=",
  Token::Type::MODOP        =>  "%=",
  Token::Type::COMMA        =>  ",",
  Token::Type::POINT        =>  ".",
  Token::Type::COLON        =>  ":",
  Token::Type::SEMI         =>  "; ",
  Token::Type::AMPERSAND    =>  "&",
  Token::Type::PIPE         =>  "|",
  Token::Type::LPAREN       =>  "(",
  Token::Type::RPAREN       =>  ")",
  Token::Type::LBRACE       =>  "[",
  Token::Type::RBRACE       =>  "]",
  Token::Type::LCURLY       =>  "{",
  Token::Type::RCURLY       =>  "}",
  Token::Type::STAB         =>  "->",
  Token::Type::EOF          =>  "\0",
  Token::Type::NEWLINE      =>  "\n",
  Token::Type::WHITESPACE   =>  " ",
  Token::Type::REQUIRE      =>  "require",
  Token::Type::INCLUDE      =>  "include",
  Token::Type::EXTEND       =>  "extend",
  Token::Type::DEFMODULE    =>  "defmodule",
  Token::Type::DEFTYPE      =>  "deftype",
  Token::Type::DEFSTATIC    =>  "defstatic",
  Token::Type::DEF          =>  "def",
  Token::Type::FN           =>  "fn",
  Token::Type::DO           =>  "do",
  Token::Type::UNLESS       =>  "unless",
  Token::Type::ELSE         =>  "else",
  Token::Type::WHILE        =>  "while",
  Token::Type::UNTIL        =>  "until",
  Token::Type::WHEN         =>  "when",
  Token::Type::END          =>  "end",
  Token::Type::RETURN       =>  "return",
  Token::Type::BREAK        =>  "break",
  Token::Type::NEXT         =>  "next",
  Token::Type::RAISE        =>  "raise",
  Token::Type::RESCUE       =>  "rescue",
  Token::Type::ENSURE       =>  "ensure",
  Token::Type::SELF         =>  "self",
  Token::Type::TRUE         =>  "true",
  Token::Type::FALSE        =>  "false",
  Token::Type::NIL          =>  "nil"
}


describe "Lexer" do
  {% for type, token in STATIC_TOKENS %}
    it "lexes `" + {{token}} + "`" do
      assert_token_type {{token}}, {{type}}
    end
  {% end %}



  it "lexes comments properly" do
    assert_token_type "# some comment\n", Token::Type::COMMENT
  end

  it "lexes multiple whitespace delimiters together" do
    tokens = tokenize(" \t\t ")
    tokens.size.should eq(2) # One whitespace token, followed by the EOF.
    tokens.first.type.should eq(Token::Type::WHITESPACE)
  end

  it "lexes newlines characters separately from whitespace" do
    tokens = tokenize(" \t\n ")
    tokens.size.should eq(4) # whitespace, newline, whitespace, EOF.
    tokens[0].type.should eq(Token::Type::WHITESPACE)
    tokens[1].type.should eq(Token::Type::NEWLINE)
    tokens[2].type.should eq(Token::Type::WHITESPACE)
  end

  it "stops lexing after reaching EOF" do
    tokens = tokenize("thing\0 more things")
    tokens.size.should eq(2)
    tokens.last.type.should eq(Token::Type::EOF)
  end

  it "lexes integers" do
    assert_token_type "1",          Token::Type::INTEGER
    assert_token_type "100",        Token::Type::INTEGER
    assert_token_type "123456789",  Token::Type::INTEGER
    assert_token_type "123_456",    Token::Type::INTEGER
    assert_token_type "23_000",     Token::Type::INTEGER
    assert_token_type "45_00",      Token::Type::INTEGER
  end

  it "lexes floats" do
    assert_token_type "1.0",          Token::Type::FLOAT
    assert_token_type "100.0",        Token::Type::FLOAT
    assert_token_type "12345.6789",   Token::Type::FLOAT
    assert_token_type "123_456.789",  Token::Type::FLOAT
    assert_token_type "23.123_456",   Token::Type::FLOAT
    assert_token_type "1000.000_0",   Token::Type::FLOAT
  end

  it "lexes ? as an identifier modifier" do
    token = tokenize(%q(hello?)).first
    token.type.should eq(Token::Type::IDENT)
    token.value.should eq("hello?")
  end

  it "lexes ! as an identifier modifier" do
    token = tokenize(%q(hello!)).first
    token.type.should eq(Token::Type::IDENT)
    token.value.should eq("hello!")
  end

  it "does not allow multiple modifiers on an identifier" do
    parser = Parser.new(IO::Memory.new(%q(hello??)), File.join(Dir.current, "_.mt"))
    # Instantiating the parser will parse the first token.
    token = parser.current_token
    token.type.should eq(Token::Type::IDENT)
    # The lexer should only accept a single modifier as part of the identifier
    token.value.should eq("hello?")
  end

  it "lexes symbols" do
    assert_token_type %q(:hello), Token::Type::SYMBOL
    assert_token_type %q(:a),     Token::Type::SYMBOL
  end

  it "allows constants as symbol values" do
    assert_token_type %q(:CONST), Token::Type::SYMBOL
    assert_token_type %q(:Thing), Token::Type::SYMBOL
  end

  it "lexes symbols with spaces" do
    assert_token_type %q(:""),             Token::Type::SYMBOL
    assert_token_type %q(:"   "),          Token::Type::SYMBOL
    assert_token_type %q(:"hello, world"), Token::Type::SYMBOL
  end

  it "lexes magic constants"do
    assert_token_type %q(__FILE__),             Token::Type::MAGIC_CONST
    assert_token_type %q(__LINE__),             Token::Type::MAGIC_CONST
  end
end
