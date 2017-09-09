require "../spec_helper"

private def make_literal_node(value : Nil   ); NilLiteral.new;                  end
private def make_literal_node(value : Bool  ); BooleanLiteral.new(value);       end
private def make_literal_node(value : Int   ); IntegerLiteral.new(value.to_s);  end
private def make_literal_node(value : Float ); FloatLiteral.new(value.to_s);    end
private def make_literal_node(value : String); StringLiteral.new(value);        end
private def make_literal_node(value : Symbol); SymbolLiteral.new(value.to_s);   end
private def make_literal_node(value : Array(T)) forall T
  ListLiteral.new(value.map{ |v| (v.is_a?(Node) ? v : make_literal_node(v)).as(Node) })
end

# Check that parsing the given source succeeds. If given, additionally check
# that the result of parsing the source matches the given nodes.
private macro it_parses(source, *expected)
  it %q(parses `{{source.id}}`) do
    result = parse_program({{source}})
    {% unless expected.empty? %}
      result.should eq(Expressions.new(*{{expected}}))
    {% end %}
  end
end



include Myst::AST

describe "Parser" do
  it_parses %q(nil),    NilLiteral.new
  it_parses %q(true),   BooleanLiteral.new(true)
  it_parses %q(false),  BooleanLiteral.new(false)

  it_parses %q(1),          IntegerLiteral.new("1")
  it_parses %q(1_000),      IntegerLiteral.new("1000")
  it_parses %q(1234567890), IntegerLiteral.new("1234567890")

  it_parses %q(1.0),          FloatLiteral.new("1.0")
  it_parses %q(123.456),      FloatLiteral.new("123.456")
  it_parses %q(1_234.567_89), FloatLiteral.new("1234.56789")

  it_parses %q("hello"),        StringLiteral.new("hello")
  it_parses %q("hello\nworld"), StringLiteral.new("hello\nworld")
  it_parses %q(""),             StringLiteral.new("")
  it_parses %q("  \t  "),       StringLiteral.new("  \t  ")

  it_parses %q(:name),          SymbolLiteral.new("name")
  it_parses %q(:"hello world"), SymbolLiteral.new("hello world")

  # Identifiers not previously defined as locals are considered Calls.
  it_parses %q(what),             Call.new(nil, "what")
  it_parses %q(long_identifier),  Call.new(nil, "long_identifier")
  it_parses %q(ident_with_1234),  Call.new(nil, "ident_with_1234")

  it_parses %q(_),              Underscore.new("_")
  it_parses %q(_named),         Underscore.new("_named")
  it_parses %q(_named_longer),  Underscore.new("_named_longer")
  it_parses %q(_1234),          Underscore.new("_1234")

  it_parses %q([]),             ListLiteral.new
  it_parses %q([call]),         make_literal_node([Call.new(nil, "call")])
  it_parses %q([1, 2, 3]),      make_literal_node([1, 2, 3])
  it_parses %q(
    [
      100,
      2.42,
      "hello"
    ]
  ),                            make_literal_node([100, 2.42, "hello"])
end
