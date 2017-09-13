require "../spec_helper"
require "../support/nodes.cr"

include Myst::AST

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

# Expect the given source to raise an error when parsed. If `message` is given,
# the raised error will be expected to contain at least that content.
private macro it_does_not_parse(source, message=nil)
  it %q(does not parse `{{source.id}}`) do
    exception = expect_raises(ParseError) do
      result = parse_program({{source}})
    end

    {% if message %}
      (exception.message || "").downcase.should match({{message}})
    {% end %}
  end
end


describe "Parser" do
  # Literals

  it_parses %q(nil),    l(nil)
  it_parses %q(true),   l(true)
  it_parses %q(false),  l(false)

  it_parses %q(1),          l(1)
  it_parses %q(1_000),      l(1000)
  it_parses %q(1234567890), l(1234567890)

  it_parses %q(1.0),          l(1.0)
  it_parses %q(123.456),      l(123.456)
  it_parses %q(1_234.567_89), l(1234.56789)

  it_parses %q("hello"),        l("hello")
  it_parses %q("hello\nworld"), l("hello\nworld")
  it_parses %q(""),             l("")
  it_parses %q("  \t  "),       l("  \t  ")

  it_parses %q(:name),          l(:name)
  it_parses %q(:"hello world"), l(:"hello world")

  # Identifiers not previously defined as locals are considered Calls.
  it_parses %q(what),             Call.new(nil, "what")
  it_parses %q(long_identifier),  Call.new(nil, "long_identifier")
  it_parses %q(ident_with_1234),  Call.new(nil, "ident_with_1234")

  it_parses %q(_),              u("_")
  it_parses %q(_named),         u("_named")
  it_parses %q(_named_longer),  u("_named_longer")
  it_parses %q(_1234),          u("_1234")

  it_parses %q([]),             ListLiteral.new
  it_parses %q([call]),         l([Call.new(nil, "call")])
  it_parses %q([1, 2, 3]),      l([1, 2, 3])
  it_parses %q([  1, 3    ]),   l([1, 3])
  it_parses %q(
    [
      100,
      2.42,
      "hello"
    ]
  ),                            l([100, 2.42, "hello"])

  it_parses %q({}),             MapLiteral.new
  it_parses %q({a: 1, b: 2}),   l({ :a => 1, :b => 2 })
  it_parses %q({  a: call   }), l({ :a => Call.new(nil, "call") })
  it_parses %q(
    {
      something: "hello",
      other: 5.4
    }
  ),                            l({ :something => "hello", :other => 5.4 })



  # Infix expressions

  it_parses %q(1 || 2),         Or.new(l(1), l(2))
  it_parses %q(1 || 2 || 3),    Or.new(l(1), Or.new(l(2), l(3)))
  it_parses %q(1 && 2),         And.new(l(1), l(2))
  it_parses %q(1 && 2 && 3),    And.new(l(1), And.new(l(2), l(3)))

  it_parses %q(1 == 2),         Call.new(l(1), "==",  [l(2)])
  it_parses %q(1 != 2),         Call.new(l(1), "!=",  [l(2)])
  it_parses %q(1  < 2),         Call.new(l(1), "<",   [l(2)])
  it_parses %q(1 <= 2),         Call.new(l(1), "<=",  [l(2)])
  it_parses %q(1 >= 2),         Call.new(l(1), ">=",  [l(2)])
  it_parses %q(1  > 2),         Call.new(l(1), ">",   [l(2)])


  it_parses %q(1 + 2),          Call.new(l(1), "+",   [l(2)])
  it_parses %q(1 - 2),          Call.new(l(1), "-",   [l(2)])
  it_parses %q(1 * 2),          Call.new(l(1), "*",   [l(2)])
  it_parses %q(1 / 2),          Call.new(l(1), "/",   [l(2)])
  it_parses %q(1 % 2),          Call.new(l(1), "%",   [l(2)])
  it_parses %q("hello" * 2),    Call.new(l("hello"), "*", [l(2)])
  it_parses %q([1] - [2]),      Call.new(l([1]), "-", [l([2])])

  # Precedence
  it_parses %q(1 && 2 || 3),    Or.new(And.new(l(1), l(2)), l(3))
  it_parses %q(1 || 2 && 3),    Or.new(l(1), And.new(l(2), l(3)))
  it_parses %q(1 == 2 && 3),    And.new(Call.new(l(1), "==", [l(2)]).as(Node), l(3))
  it_parses %q(1 && 2 == 3),    And.new(l(1), Call.new(l(2), "==", [l(3)]))
  it_parses %q(1  < 2 == 3),    Call.new(Call.new(l(1), "<",  [l(2)]).as(Node), "==", [l(3)])
  it_parses %q(1 == 2  < 3),    Call.new(l(1), "==", [Call.new(l(2), "<",  [l(3)]).as(Node)])
  it_parses %q(1  + 2  < 3),    Call.new(Call.new(l(1), "+",  [l(2)]).as(Node), "<",  [l(3)])
  it_parses %q(1  < 2  + 3),    Call.new(l(1), "<",  [Call.new(l(2), "+",  [l(3)]).as(Node)])
  it_parses %q(1  * 2  + 3),    Call.new(Call.new(l(1), "*",  [l(2)]).as(Node), "+",  [l(3)])
  it_parses %q(1  + 2  * 3),    Call.new(l(1), "+",  [Call.new(l(2), "*",  [l(3)]).as(Node)])

  it_parses %q(1 * (2 || 3)),   Call.new(l(1), "*", [Or.new(l(2), l(3)).as(Node)])

  # Ensure Calls can be used as operands to infix expressions
  it_parses %q(call + other * last), Call.new(Call.new(nil, "call"), "+", [Call.new(Call.new(nil, "other"), "*", [Call.new(nil, "last").as(Node)]).as(Node)])



  # Assignments

  it_parses %q(a = b),      SimpleAssign.new(v("a"), Call.new(nil, "b"))
  it_parses %q(a = b = c),  SimpleAssign.new(v("a"), SimpleAssign.new(v("b"), Call.new(nil, "c")))
  # Precedence with logical operations is odd.
  # An assignment with a logical operation as an argument considers the logical as higher priority.
  it_parses %q(a = 1 && 2),  SimpleAssign.new(v("a"), And.new(l(1), l(2)))
  it_parses %q(a = 1 || 2),  SimpleAssign.new(v("a"), Or.new(l(1), l(2)))
  # A logical operation with an assignment as an argument considers the assignment as higher priority.
  it_parses %q(1 && b = 2),  And.new(l(1), SimpleAssign.new(v("b"), l(2)))
  it_parses %q(1 || b = 2),  Or.new(l(1), SimpleAssign.new(v("b"), l(2)))
  # Assignments take over the remainder of the expression when appearing in a logical operation.
  it_parses %q(1 || b = 2 && 3), Or.new(l(1), SimpleAssign.new(v("b"), And.new(l(2), l(3))))
  it_parses %q(1 || b = 2 + c = 3 || 4), Or.new(l(1), SimpleAssign.new(v("b"), Call.new(l(2), "+", [SimpleAssign.new(v("c"), Or.new(l(3), l(4))).as(Node)])))
  # Assignments within parentheses are contained by them.
  it_parses %q(1 || (b = 2) && 3), Or.new(l(1), And.new(SimpleAssign.new(v("b"), l(2)), l(3)))
  # Once a variable has been assigned, future references to it should be a Var, not a Call.
  it_parses %q(
    a
    a = 2
    a
  ),              Call.new(nil, "a"), SimpleAssign.new(v("a"), l(2)), v("a")
  # Underscores can be the target of an assignment, and they should be declared in the current scope.
  it_parses %q(_ = 2),  SimpleAssign.new(u("_"), l(2))

  # Assignments can not be made to l values.
  it_does_not_parse %q(2 = 4),          /cannot assign to literal value/i
  it_does_not_parse %q(2.56 = 4),       /cannot assign to literal value/i
  it_does_not_parse %q("hi" = 4),       /cannot assign to literal value/i
  it_does_not_parse %q(nil = 4),        /cannot assign to literal value/i
  it_does_not_parse %q(false = true),   /cannot assign to literal value/i
  it_does_not_parse %q([1, 2, 3] = 4),  /cannot assign to literal value/i



  # Expression delimiters

  # Newlines can be used to delimit complete expressions
  it_parses %q(
    a = 1
    a + 2
  ),              SimpleAssign.new(v("a"), l(1)), Call.new(v("a"), "+", [l(2)])
  it_parses %q(
    nil
    [4, 5]
  ),              l(nil), l([4, 5])
  # Semicolons can also be used to place multiple expressions on a single line
  it_parses %q(
    a = 1; a + 2;
    b = 2;
  ),              SimpleAssign.new(v("a"), l(1)), Call.new(v("a"), "+", [l(2)]), SimpleAssign.new(v("b"), l(2))
  # Without the semicolon, a syntax error should occur
  it_does_not_parse %q(a = 1 b = 2)
  # Expression with operators must include the operator on the first line, but
  # the rest of the expression may flow to multiple lines.
  it_parses %q(
    a =
      [
        1,
        2
      ]
  ),              SimpleAssign.new(v("a"), l([1, 2]))
  it_parses %q(
    var1 +
    var2
  ),              Call.new(Call.new(nil, "var1"), "+", [Call.new(nil, "var2").as(Node)])
  it_does_not_parse %q(
    var1
    + var2
  )



  # Method definitions

  it_parses %q(
    def foo
    end
  ),                          Def.new("foo") # `@body` will be a Nop
  # Semicolons can be used as delimiters to compact the definition.
  it_parses %q(def foo; end), Def.new("foo")

  it_parses %q(
    def foo(a, b)
    end
  )

  it_parses %q(def foo(); end),           Def.new("foo")
  it_parses %q(def foo(a); end),          Def.new("foo", [Param.new(name: "a")])
  it_parses %q(def foo(a, b); end),       Def.new("foo", [Param.new(name: "a"), Param.new(name: "b")])
  it_parses %q(def foo(_, _second); end), Def.new("foo", [Param.new(name: "_"), Param.new(name: "_second")])

  it_parses %q(
    def foo
      1 + 2
    end
  ),            Def.new("foo", body: Expressions.new(Call.new(l(1), "+", [l(2)])))

  it_parses %q(
    def foo
      a = 1
      a * 4
    end
  ),            Def.new("foo", body: Expressions.new(SimpleAssign.new(v("a"), l(1)), Call.new(v("a"), "*", [l(4)])))

  # A Splat collector can appear anywhere in the param list
  it_parses %q(def foo(*a); end),       Def.new("foo", [Param.new(name: "a", splat: true)], splat_index: 0)
  it_parses %q(def foo(*a, b); end),    Def.new("foo", [Param.new(name: "a", splat: true), Param.new(name: "b")], splat_index: 0)
  it_parses %q(def foo(a, *b); end),    Def.new("foo", [Param.new(name: "a"), Param.new(name: "b", splat: true)], splat_index: 1)
  it_parses %q(def foo(a, *b, c); end), Def.new("foo", [Param.new(name: "a"), Param.new(name: "b", splat: true), Param.new(name: "c")], splat_index: 1)

  # Multiple splat collectors are not allowed in the param list
  it_does_not_parse %q(def foo(*a, *b); end), /multiple splat parameters/

  # A Block parameter must be the last parameter in the param list
  it_parses %q(def foo(&block); end), Def.new("foo", block_param: Param.new(name: "block", block: true))
  it_parses %q(def foo(a, &block); end), Def.new("foo", [Param.new(name: "a")], block_param: Param.new(name: "block", block: true))
  it_parses %q(def foo(a, *b, &block); end), Def.new("foo", [Param.new(name: "a"), Param.new(name: "b", splat: true)], block_param: Param.new(name: "block", block: true), splat_index: 1)

  it_does_not_parse %q(def foo(&block, a); end), /block parameter/

  it_parses %q(
    def foo; end
    def foo; end
  ),                Def.new("foo"), Def.new("foo")
end
