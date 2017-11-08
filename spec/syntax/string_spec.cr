require "../spec_helper"

private def assert_token_type(source, token_type)
  token = tokenize(source).first
  token.type.should eq(token_type)
end

private def it_lexes_the_single_token(source, token_type)
  it "lexes `#{source}` as a single #{token_type} token" do
    tokens = tokenize(source)
    # An `EOF` token is always added at the end by the tokenizer, so asserting
    # that a single token was lexed means checking for 2 tokens in the stream.
    tokens.size.should eq(2)
    tokens.first.type.should eq(token_type)
  end
end


describe "Lexer - Simple strings" do
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
      assert_token_type %Q("\\#{escape}"),   Token::Type::STRING
    end
  end
end


# The lexer does not currently actually differentiate regular strings from
# interpolated strings. Instead, it simply scans until it encounters the
# closing quote character. It determines that character by tracking brace
# characters on a stack and popping them when the matching closing brace is
# encountered.
#
# The actual parsing of the interpolations is handled by the Parser.
describe "Lexer - Interpolated Strings" do
  # Empty interpolations
  it_lexes_the_single_token %q("#{}"),              Token::Type::STRING
  it_lexes_the_single_token %q("hello#{}"),         Token::Type::STRING
  it_lexes_the_single_token %q("#{}, world"),       Token::Type::STRING
  it_lexes_the_single_token %q("hello#{}, world"),  Token::Type::STRING

  # Simple expressions
  it_lexes_the_single_token %q("#{a}"),             Token::Type::STRING
  it_lexes_the_single_token %q("#{1}"),             Token::Type::STRING
  it_lexes_the_single_token %q("#{""}"),            Token::Type::STRING

  # Complex expressions
  it_lexes_the_single_token %q("#{[]}"),            Token::Type::STRING
  it_lexes_the_single_token %q("2 is #{1 + 1}"),    Token::Type::STRING

  # Maps and brace blocks in interpolations are potentially ambiguous.
  # Syntax errors here are hard to source properly.
  it_lexes_the_single_token %q("#{[1,2].map{ |e| e*2 }}"),    Token::Type::STRING
  it_lexes_the_single_token %q("#{[1,2].map{ |e| "#{e}" }}"), Token::Type::STRING
  it_lexes_the_single_token %q("#{{}}"),                      Token::Type::STRING
  it_lexes_the_single_token %q("#{ {} }"),                    Token::Type::STRING
  it_lexes_the_single_token %q("#{{a: "#{b}"}}"),             Token::Type::STRING


  # Nested interpolations
  it_lexes_the_single_token %q("#{ "#{b}" }"),      Token::Type::STRING

  # Multiple interpolations
  it_lexes_the_single_token %q("hello, #{first_name} #{last_name}"),  Token::Type::STRING
  it_lexes_the_single_token %q("#{first_name}#{last_name}"),          Token::Type::STRING
  it_lexes_the_single_token %q("hello, #{first_name}, or #{other}"),  Token::Type::STRING
end
