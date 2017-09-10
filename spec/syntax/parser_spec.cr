require "../spec_helper"

private def literal(value : Node  );  value; end
private def literal(value : Nil   );  NilLiteral.new;                           end
private def literal(value : Bool  );  BooleanLiteral.new(value).as(Node);       end
private def literal(value : Int   );  IntegerLiteral.new(value.to_s).as(Node);  end
private def literal(value : Float );  FloatLiteral.new(value.to_s).as(Node);    end
private def literal(value : String);  StringLiteral.new(value).as(Node);        end
private def literal(value : Symbol);  SymbolLiteral.new(value.to_s).as(Node);   end
private def literal(value : Array(T)) forall T
  ListLiteral.new(value.map{ |v| (v.is_a?(Node) ? v : literal(v)).as(Node) }).as(Node)
end
private def literal(value : Hash(K, V)) forall K, V
  entries = value.map do |k, v|
    MapLiteral::Entry.new(key: literal(k), value: literal(v))
  end

  MapLiteral.new(entries).as(Node)
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
  # Literals

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
  it_parses %q([call]),         literal([Call.new(nil, "call")])
  it_parses %q([1, 2, 3]),      literal([1, 2, 3])
  it_parses %q([  1, 3    ]),   literal([1, 3])
  it_parses %q(
    [
      100,
      2.42,
      "hello"
    ]
  ),                            literal([100, 2.42, "hello"])

  it_parses %q({}),             MapLiteral.new
  it_parses %q({a: 1, b: 2}),   literal({ :a => 1, :b => 2 })
  it_parses %q({  a: call   }), literal({ :a => Call.new(nil, "call") })
  it_parses %q(
    {
      something: "hello",
      other: 5.4
    }
  ),                            literal({ :something => "hello", :other => 5.4 })



  # Infix expressions

  it_parses %q(1 || 2),         Or.new(literal(1), literal(2))
  it_parses %q(1 || 2 || 3),    Or.new(literal(1), Or.new(literal(2), literal(3)))
  it_parses %q(1 && 2),         And.new(literal(1), literal(2))
  it_parses %q(1 && 2 && 3),    And.new(literal(1), And.new(literal(2), literal(3)))

  it_parses %q(1 == 2),         Call.new(literal(1), "==",  [literal(2)])
  it_parses %q(1 != 2),         Call.new(literal(1), "!=",  [literal(2)])
  it_parses %q(1  < 2),         Call.new(literal(1), "<",   [literal(2)])
  it_parses %q(1 <= 2),         Call.new(literal(1), "<=",  [literal(2)])
  it_parses %q(1 >= 2),         Call.new(literal(1), ">=",  [literal(2)])
  it_parses %q(1  > 2),         Call.new(literal(1), ">",   [literal(2)])


  it_parses %q(1 + 2),          Call.new(literal(1), "+",   [literal(2)])
  it_parses %q(1 - 2),          Call.new(literal(1), "-",   [literal(2)])
  it_parses %q(1 * 2),          Call.new(literal(1), "*",   [literal(2)])
  it_parses %q(1 / 2),          Call.new(literal(1), "/",   [literal(2)])
  it_parses %q(1 % 2),          Call.new(literal(1), "%",   [literal(2)])
  it_parses %q("hello" * 2),    Call.new(literal("hello"), "*", [literal(2)])
  it_parses %q([1] - [2]),      Call.new(literal([1]), "-", [literal([2])])

  # Precedence
  it_parses %q(1 && 2 || 3),    Or.new(And.new(literal(1), literal(2)), literal(3))
  it_parses %q(1 || 2 && 3),    Or.new(literal(1), And.new(literal(2), literal(3)))
  it_parses %q(1 == 2 && 3),    And.new(Call.new(literal(1), "==", [literal(2)]).as(Node), literal(3))
  it_parses %q(1 && 2 == 3),    And.new(literal(1), Call.new(literal(2), "==", [literal(3)]))
  it_parses %q(1  < 2 == 3),    Call.new(Call.new(literal(1), "<",  [literal(2)]).as(Node), "==", [literal(3)])
  it_parses %q(1 == 2  < 3),    Call.new(literal(1), "==", [Call.new(literal(2), "<",  [literal(3)]).as(Node)])
  it_parses %q(1  + 2  < 3),    Call.new(Call.new(literal(1), "+",  [literal(2)]).as(Node), "<",  [literal(3)])
  it_parses %q(1  < 2  + 3),    Call.new(literal(1), "<",  [Call.new(literal(2), "+",  [literal(3)]).as(Node)])
  it_parses %q(1  * 2  + 3),    Call.new(Call.new(literal(1), "*",  [literal(2)]).as(Node), "+",  [literal(3)])
  it_parses %q(1  + 2  * 3),    Call.new(literal(1), "+",  [Call.new(literal(2), "*",  [literal(3)]).as(Node)])

  it_parses %q(1 * (2 || 3)),   Call.new(literal(1), "*", [Or.new(literal(2), literal(3)).as(Node)])

  # Ensure Calls can be used as operands to infix expressions
  it_parses %q(call + other * last), Call.new(Call.new(nil, "call"), "+", [Call.new(Call.new(nil, "other"), "*", [Call.new(nil, "last").as(Node)]).as(Node)])



  # Assignments

  it_parses %q(a = b),      SimpleAssign.new(Var.new("a"), Call.new(nil, "b"))
  it_parses %q(a = b = c),  SimpleAssign.new(Var.new("a"), SimpleAssign.new(Var.new("b"), Call.new(nil, "c")))

  # Precedence with logical operations is odd.
  # An assignment with a logical operation as an argument considers the logical as higher priority.
  it_parses %q(a = 1 && 2),  SimpleAssign.new(Var.new("a"), And.new(literal(1), literal(2)))
  it_parses %q(a = 1 || 2),  SimpleAssign.new(Var.new("a"), Or.new(literal(1), literal(2)))
  # A logical operation with an assignment as an argument considers the assignment as higher priority.
  it_parses %q(1 && b = 2),  And.new(literal(1), SimpleAssign.new(Var.new("b"), literal(2)))
  it_parses %q(1 || b = 2),  Or.new(literal(1), SimpleAssign.new(Var.new("b"), literal(2)))

  # Assignments take over the remainder of the expression when appearing in a logical operation.
  it_parses %q(1 || b = 2 && 3), Or.new(literal(1), SimpleAssign.new(Var.new("b"), And.new(literal(2), literal(3))))
  it_parses %q(1 || b = 2 + c = 3 || 4), Or.new(literal(1), SimpleAssign.new(Var.new("b"), Call.new(literal(2), "+", [SimpleAssign.new(Var.new("c"), Or.new(literal(3), literal(4))).as(Node)])))

  # Assignments within parentheses are contained by them.
  it_parses %q(1 || (b = 2) && 3), Or.new(literal(1), And.new(SimpleAssign.new(Var.new("b"), literal(2)), literal(3)))

  # Once a variable has been assigned, future references to it should be a Var, not a Call.
  it_parses %q(
    a
    a = 2
    a
  ),              Call.new(nil, "a"), SimpleAssign.new(Var.new("a"), literal(2)), Var.new("a")
end
