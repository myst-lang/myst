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


private macro test_calls_with_receiver(receiver_source, receiver_node)
  # Bare identifiers are considered calls, as long as they have not already been defined as Vars.
  it_parses %q({{receiver_source.id}}call),            Call.new({{receiver_node}}, "call")
  it_parses %q({{receiver_source.id}}call()),          Call.new({{receiver_node}}, "call")
  it_parses %q({{receiver_source.id}}call(1)),         Call.new({{receiver_node}}, "call", [l(1)])
  it_parses %q({{receiver_source.id}}call(1, 2 + 3)),  Call.new({{receiver_node}}, "call", [l(1), Call.new(l(2), "+", [l(3)])])
  it_parses %q({{receiver_source.id}}call (1)),        Call.new({{receiver_node}}, "call", [l(1)])
  it_parses %q(
    {{receiver_source.id}}call(
      1,
      2
    )
  ),                            Call.new({{receiver_node}}, "call", [l(1), l(2)])
  it_parses %q(
    {{receiver_source.id}}call(
    )
  ),                            Call.new({{receiver_node}}, "call")
  # Calls with parameters _must_ wrap them in parentheses.
  it_does_not_parse %q({{receiver_source.id}}call a, b)

  # Blocks can be given to a Call as either brace blocks (`{}`) or `do...end` constructs.
  it_parses %q({{receiver_source.id}}call{ }),     Call.new({{receiver_node}}, "call", block: Block.new)
  it_parses %q({{receiver_source.id}}call   { }),  Call.new({{receiver_node}}, "call", block: Block.new)
  it_parses %q(
    {{receiver_source.id}}call do
    end
  ),                              Call.new({{receiver_node}}, "call", block: Block.new)
  it_parses %q(
    {{receiver_source.id}}call    do
    end
  ),                              Call.new({{receiver_node}}, "call", block: Block.new)

  # The `do...end` syntax can also have a delimiter after the `do` and parameters.
  it_parses %q({{receiver_source.id}}call do; end),    Call.new({{receiver_node}}, "call", block: Block.new)
  it_parses %q({{receiver_source.id}}call   do; end),  Call.new({{receiver_node}}, "call", block: Block.new)

  # Brace blocks accept arguments after the opening brace.
  it_parses %q({{receiver_source.id}}call{ |a,b| }),             Call.new({{receiver_node}}, "call", block: Block.new([p("a"), p("b")]))
  # Block parameters are exactly like normal Def parameters, with the same syntax support.
  it_parses %q({{receiver_source.id}}call{ | | }),               Call.new({{receiver_node}}, "call", block: Block.new())
  it_parses %q({{receiver_source.id}}call{ |a,*b| }),            Call.new({{receiver_node}}, "call", block: Block.new([p("a"), p("b", splat: true)]))
  it_parses %q({{receiver_source.id}}call{ |1,nil=:thing| }),    Call.new({{receiver_node}}, "call", block: Block.new([p(nil, l(1)), p("thing", l(nil))]))
  it_parses %q({{receiver_source.id}}call{ |<other>| }),         Call.new({{receiver_node}}, "call", block: Block.new([p(nil, i(Call.new(nil, "other")))]))
  it_parses %q({{receiver_source.id}}call{ |*a,b| }),            Call.new({{receiver_node}}, "call", block: Block.new([p("a", splat: true), p("b")]))
  it_parses %q({{receiver_source.id}}call{ |a,*b,c| }),          Call.new({{receiver_node}}, "call", block: Block.new([p("a"), p("b", splat: true), p("c")]))
  it_parses %q({{receiver_source.id}}call{ |a,&block| }),        Call.new({{receiver_node}}, "call", block: Block.new([p("a")], block_param: p("block", block: true)))
  it_parses %q({{receiver_source.id}}call{ |a,&b| }),            Call.new({{receiver_node}}, "call", block: Block.new([p("a")], block_param: p("b", block: true)))
  it_parses %q({{receiver_source.id}}call{ |a,
                                          &b| }),             Call.new({{receiver_node}}, "call", block: Block.new([p("a")], block_param: p("b", block: true)))

  it_does_not_parse %q({{receiver_source.id}}call{ |&b,a| }),     /block parameter/
  it_does_not_parse %q({{receiver_source.id}}call{ |*a,*b| }),    /multiple splat/

  # `do...end` blocks accept arguments accept arguments
  it_parses %q(
    {{receiver_source.id}}call do | |
    end
  ),                Call.new({{receiver_node}}, "call", block: Block.new())
  it_parses %q(
    {{receiver_source.id}}call do |a,*b|
    end
  ),                Call.new({{receiver_node}}, "call", block: Block.new([p("a"), p("b", splat: true)]))
  it_parses %q(
    {{receiver_source.id}}call do |*a,b|
    end
  ),                Call.new({{receiver_node}}, "call", block: Block.new([p("a", splat: true), p("b")]))
  it_parses %q(
    {{receiver_source.id}}call do |a,*b,c|
    end
  ),                Call.new({{receiver_node}}, "call", block: Block.new([p("a"), p("b", splat: true), p("c")]))
  it_parses %q(
    {{receiver_source.id}}call do |a,&block|
    end
  ),                Call.new({{receiver_node}}, "call", block: Block.new([p("a")], block_param: p("block", block: true)))
  it_parses %q(
    {{receiver_source.id}}call do |a,&b|
    end
  ),                Call.new({{receiver_node}}, "call", block: Block.new([p("a")], block_param: p("b", block: true)))
  it_parses %q(
    {{receiver_source.id}}call do |a,
              &b|
    end
  ),                Call.new({{receiver_node}}, "call", block: Block.new([p("a")], block_param: p("b", block: true)))

  it_does_not_parse %q(
    {{receiver_source.id}}call do |&b,a|
    end
  ),                      /block parameter/
  it_does_not_parse %q(
    {{receiver_source.id}}call do |*a,*b|
    end
  ),                      /multiple splat/

  it_does_not_parse %q(
    {{receiver_source.id}}call{
      |arg|
    }
  )
  it_does_not_parse %q(
    {{receiver_source.id}}call do
      |arg|
    end
  )

  # Calls with arguments _and_ blocks provide the block after the closing parenthesis.
  it_parses %q({{receiver_source.id}}call(1, 2){ }),  Call.new({{receiver_node}}, "call", [l(1), l(2)], block: Block.new)
  it_parses %q(
    {{receiver_source.id}}call(1, 2) do
    end
  ),                            Call.new({{receiver_node}}, "call", [l(1), l(2)], block: Block.new)

  # Calls with blocks that are within other calls can also accept blocks.
  it_parses %q(call({{receiver_source.id}}inner(1){ })),  Call.new(nil, "call", [Call.new({{receiver_node}}, "inner", [l(1)], block: Block.new).as(Node)])
  it_parses %q(
    call({{receiver_source.id}}inner(1) do
    end)
  ),                                Call.new(nil, "call", [Call.new({{receiver_node}}, "inner", [l(1)], block: Block.new).as(Node)])
  it_parses %q(call(1, {{receiver_source.id}}inner(1){ }, 2)),  Call.new(nil, "call", [l(1), Call.new({{receiver_node}}, "inner", [l(1)], block: Block.new), l(2)])
  it_parses %q(
    call(1, {{receiver_source.id}}inner(1) do
    end, 2)
  ),                                      Call.new(nil, "call", [l(1), Call.new({{receiver_node}}, "inner", [l(1)], block: Block.new), l(2)])

  # Blocks are exactly like normal defs, they can contain any valid Expressions node as a body.
  it_parses %q({{receiver_source.id}}call{ a = 1; a }), Call.new({{receiver_node}}, "call", block: Block.new(body: e(SimpleAssign.new(v("a"), l(1)), v("a"))))
  it_parses %q({{receiver_source.id}}call{
      a = 1
      a
    }
  ), Call.new({{receiver_node}}, "call", block: Block.new(body: e(SimpleAssign.new(v("a"), l(1)), v("a"))))
  it_parses %q({{receiver_source.id}}call do
      a = 1
      a
    end
  ), Call.new({{receiver_node}}, "call", block: Block.new(body: e(SimpleAssign.new(v("a"), l(1)), v("a"))))
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

  it_parses %q(Thing),          c("Thing")
  it_parses %q(A),              c("A")
  it_parses %q(ANOTHER),        c("ANOTHER")
  it_parses %q(UNDER_SCORES),   c("UNDER_SCORES")

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



  # Value interpolations

  # Any literal value is valid in an interpolation.
  it_parses %q(<nil>),          i(nil)
  it_parses %q(<true>),         i(true)
  it_parses %q(<false>),        i(false)
  it_parses %q(<1>),            i(1)
  it_parses %q(<1.5>),          i(1.5)
  it_parses %q(<"hi">),         i("hi")
  it_parses %q(<:hello>),       i(:hello)
  it_parses %q(<:"hi there">),  i(:"hi there")
  it_parses %q(<[1, 2]>),       i([1, 2])
  it_parses %q(<{a: 1}>),       i({:a => 1})
  # Calls, Vars, Consts, Underscores are also valid.
  it_parses %q(<a>),            i(Call.new(nil, "a"))
  it_parses %q(<a(1, 2)>),      i(Call.new(nil, "a", [l(1), l(2)]))
  it_parses %q(<a.b(1)>),       i(Call.new(Call.new(nil, "a"), "b", [l(1)]))
  it_parses %q(<a.b.c>),        i(Call.new(Call.new(Call.new(nil, "a"), "b"), "c"))
  it_parses %q(<a{ }>),         i(Call.new(nil, "a", block: Block.new))
  it_parses %q(<a do; end>),    i(Call.new(nil, "a", block: Block.new))
  it_parses %q(<Thing>),        i(c("Thing"))
  it_parses %q(<Thing.Other>),  i(Call.new(c("Thing"), "Other"))
  it_parses %q(<A.B.C>),        i(Call.new(Call.new(c("A"), "B"), "C"))
  it_parses %q(<_>),            i(u("_"))
  # Complex expressions must be wrapped in parentheses.
  it_parses %q(<(a)>),          i(Call.new(nil, "a"))
  it_parses %q(<(1 + 2)>),      i(Call.new(l(1), "+", [l(2)]))
  it_does_not_parse %q(<1 + 2>)
  it_does_not_parse %q(<a + b>)
  it_does_not_parse %q(< a + b >)
  # Interpolations can span multiple lines if necessary.
  it_parses %q(<
    a
  >),                           i(Call.new(nil, "a"))
  it_parses %q(<
    (1 + 2)
  >),                           i(Call.new(l(1), "+", [l(2)]))
  # Interpolations can also be used as Map keys.
  it_parses %q(
    {
      <1>: "int",
      <nil>: :nil
    }
  ),                            l({ i(1) => "int", i(nil) => :nil })
  # Interpolations can be used as a replacement for any primary expression.
  it_parses %q([1, <2>, 3]),    l([1, i(2), 3])
  it_parses %q(<3> + 4),        Call.new(i(3), "+", [l(4)])


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



  # Simple Assignments

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
  # Consts and Underscores can also be the target of an assignment, and they
  # should be declared in the current scope.
  it_parses %q(THING = 4),  SimpleAssign.new(c("THING"), l(4))
  it_parses %q(_ = 2),      SimpleAssign.new(u("_"), l(2))

  # Assignments can not be made to literal values.
  it_does_not_parse %q(2 = 4),          /cannot assign to literal value/i
  it_does_not_parse %q(2.56 = 4),       /cannot assign to literal value/i
  it_does_not_parse %q("hi" = 4),       /cannot assign to literal value/i
  it_does_not_parse %q(nil = 4),        /cannot assign to literal value/i
  it_does_not_parse %q(false = true),   /cannot assign to literal value/i
  it_does_not_parse %q([1, 2, 3] = 4),  /cannot assign to literal value/i



  # Match Assignments

  # Match assignments allow literal values on either side
  it_parses %q(1 =: 1),           MatchAssign.new(l(1), l(1))
  it_parses %q(:hi =: "hi"),      MatchAssign.new(l(:hi), l("hi"))
  it_parses %q(true =: false),    MatchAssign.new(l(true), l(false))
  it_parses %q([1, 2] =: [1, 2]), MatchAssign.new(l([1, 2]), l([1, 2]))
  it_parses %q({a: 2} =: {a: 2}), MatchAssign.new(l({:a => 2}),l({:a => 2}))
  # Vars, Consts, and Underscores can also be used on either side.
  it_parses %q(a =: 5),           MatchAssign.new(v("a"), l(5))
  it_parses %q(Thing =: 10),      MatchAssign.new(c("Thing"), l(10))
  it_parses %q(_ =: 15),          MatchAssign.new(u("_"), l(15))
  # Value Interpolations are also allowed on either side for complex patterns/values.
  it_parses %q(<a> =: <b>),       MatchAssign.new(i(Call.new(nil, "a")), i(Call.new(nil, "b")))
  # Bare multiple assignment is not allowed. Use a List pattern instead.
  it_does_not_parse %q(a, b =: 1, 2)
  # The value of a match assignment may appear on a new line.
  it_parses %q(
    a =:
      4
  ),            MatchAssign.new(v("a"), l(4))
  # Patterns can be arbitrarily nested.
  it_parses %q(
    [1, {
      a: a,
      b: b
    }, 4] =:
      thing
  ),            MatchAssign.new(l([1, { :a => v("a"), :b => v("b") }, 4]), Call.new(nil, "thing"))

  # Matches can be chained with other matches, as well as simple assignments.
  it_parses %q(
    a = 3 =: b
  ),            SimpleAssign.new(v("a"), MatchAssign.new(l(3), Call.new(nil, "b")))
  it_parses %q(
    3 =: a = b
  ),            MatchAssign.new(l(3), SimpleAssign.new(v("a"), Call.new(nil, "b")))
  it_parses %q(
    3 =: a =: 3
  ),            MatchAssign.new(l(3), MatchAssign.new(v("a"), l(3)))



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
  it_parses %q(def foo(a); end),          Def.new("foo", [p("a")])
  it_parses %q(def foo(a, b); end),       Def.new("foo", [p("a"), p("b")])
  it_parses %q(def foo(_, _second); end), Def.new("foo", [p("_"), p("_second")])

  it_parses %q(
    def foo
      1 + 2
    end
  ),            Def.new("foo", body: e(Call.new(l(1), "+", [l(2)])))

  it_parses %q(
    def foo
      a = 1
      a * 4
    end
  ),            Def.new("foo", body: e(SimpleAssign.new(v("a"), l(1)), Call.new(v("a"), "*", [l(4)])))

  # A Splat collector can appear anywhere in the param list
  it_parses %q(def foo(*a); end),       Def.new("foo", [p("a", splat: true)], splat_index: 0)
  it_parses %q(def foo(*a, b); end),    Def.new("foo", [p("a", splat: true), p("b")], splat_index: 0)
  it_parses %q(def foo(a, *b); end),    Def.new("foo", [p("a"), p("b", splat: true)], splat_index: 1)
  it_parses %q(def foo(a, *b, c); end), Def.new("foo", [p("a"), p("b", splat: true), p("c")], splat_index: 1)

  # Multiple splat collectors are not allowed in the param list
  it_does_not_parse %q(def foo(*a, *b); end), /multiple splat parameters/

  # A Block parameter must be the last parameter in the param list
  it_parses %q(def foo(&block); end), Def.new("foo", block_param: p("block", block: true))
  it_parses %q(def foo(a, &block); end), Def.new("foo", [p("a")], block_param: p("block", block: true))
  it_parses %q(def foo(a, *b, &block); end), Def.new("foo", [p("a"), p("b", splat: true)], block_param: p("block", block: true), splat_index: 1)
  # The block parameter may also be given any name
  it_parses %q(def foo(a, &b); end), Def.new("foo", [p("a")], block_param: p("b", block: true))
  it_parses %q(def foo(a, &_); end), Def.new("foo", [p("a")], block_param: p("_", block: true))

  it_does_not_parse %q(def foo(&block, a); end),        /block parameter/
  it_does_not_parse %q(def foo(&block1, &block2); end), /block parameter/
  it_does_not_parse %q(def foo(a, &block, c); end),     /block parameter/

  it_parses %q(
    def foo; end
    def foo; end
  ),                Def.new("foo"), Def.new("foo")

  # References to variables defined as parameters should be considered Vars,
  # not Calls. To maintain consistency in the call syntax, this does not apply
  # to the block parameter
  it_parses %q(def foo(a); a; end),           Def.new("foo", [p("a")], e(v("a")))
  it_parses %q(def foo(&block); block; end),  Def.new("foo", block_param: p("block", block: true), body: e(Call.new(nil, "block")))

  # The Vars defined within the Def should be removed after the Def finishes.
  it_parses %q(def foo(a); end; a), Def.new("foo", [p("a")]), Call.new(nil, "a")

  # Defs allow patterns as parameters
  it_parses %q(def foo(nil); end),          Def.new("foo", [p(nil, l(nil))])
  it_parses %q(def foo(1, 2); end),         Def.new("foo", [p(nil, l(1)), p(nil, l(2))])
  it_parses %q(def foo([1, a]); end),       Def.new("foo", [p(nil, l([1, v("a")]))])
  it_parses %q(def foo({a: 1, b: b}); end), Def.new("foo", [p(nil, l({ :a => 1, :b => v("b") }))])
  # Patterns can also be followed by a name to capture the entire argument.
  it_parses %q(def foo([1, a] =: b); end),  Def.new("foo", [p("b", l([1, v("a")]))])
  it_parses %q(def foo([1, _] =: _); end),  Def.new("foo", [p("_", l([1, u("_")]))])
  it_parses %q(def foo(<other> =: _); end), Def.new("foo", [p("_", i(Call.new(nil, "other")))])



  # Module definitions

  it_parses %q(
    module Foo
    end
  ),                              ModuleDef.new("Foo")
  it_parses %q(module Foo; end),  ModuleDef.new("Foo")
  it_parses %q(
    module Foo
      def foo; end
    end
  ),                ModuleDef.new("Foo", e(Def.new("foo")))
  # Modules allow immediate code evaluation on their scope.
  it_parses %q(
    module Foo
      1 + 2
      a = 3
    end
  ),                ModuleDef.new("Foo", e(Call.new(l(1), "+", [l(2)]), SimpleAssign.new(v("a"), l(3))))
  # Modules can also be nested
  it_parses %q(
    module Foo
      module Bar
      end
    end
  ),                ModuleDef.new("Foo", e(ModuleDef.new("Bar")))



  # Calls

  test_calls_with_receiver("",                  nil)
  test_calls_with_receiver("object.",           Call.new(nil, "object"))
  test_calls_with_receiver("nested.object.",    Call.new(Call.new(nil, "nested"), "object"))
  test_calls_with_receiver("Thing.member.",     Call.new(c("Thing"), "member"))
  test_calls_with_receiver("Thing.Other.",      Call.new(c("Thing"), "Other"))
  test_calls_with_receiver("1.",                l(1))
  test_calls_with_receiver("[1, 2, 3].",        l([1, 2, 3]))
  test_calls_with_receiver(%q("some string".),  l("some string"))
  test_calls_with_receiver(%q(method{ }.),      Call.new(nil, "method", block: Block.new))
  test_calls_with_receiver(%q(method do; end.), Call.new(nil, "method", block: Block.new))
end
