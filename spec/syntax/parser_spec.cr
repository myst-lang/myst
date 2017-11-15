require "../spec_helper"
require "../support/nodes.cr"

# Check that parsing the given source succeeds. If given, additionally check
# that the result of parsing the source matches the given nodes.
private def it_parses(source, *expected, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  it %Q(parses `#{source}`), file, line, end_line do
    result = parse_program(source)
    unless expected.empty?
      result.should eq(Expressions.new(*expected))
    end
  end
end

# Expect the given source to raise an error when parsed. If `message` is given,
# the raised error will be expected to contain at least that content.
private def it_does_not_parse(source, message=nil, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  it %Q(does not parse `#{source}`), file, line, end_line do
    exception = expect_raises(ParseError) do
      result = parse_program(source)
    end

    if message
      (exception.message || "").downcase.should match(message)
    end
  end
end


private def test_calls_with_receiver(receiver_source, receiver_node)
  it_parses %Q(#{receiver_source}call),             Call.new(receiver_node, "call")
  it_parses %Q(#{receiver_source}call?),            Call.new(receiver_node, "call?")
  it_parses %Q(#{receiver_source}call!),            Call.new(receiver_node, "call!")
  it_parses %Q(#{receiver_source}call()),           Call.new(receiver_node, "call")
  it_parses %Q(#{receiver_source}call?()),          Call.new(receiver_node, "call?")
  it_parses %Q(#{receiver_source}call!()),          Call.new(receiver_node, "call!")
  it_parses %Q(#{receiver_source}call(1)),          Call.new(receiver_node, "call", [l(1)])
  it_parses %Q(#{receiver_source}call(1, 2 + 3)),   Call.new(receiver_node, "call", [l(1), Call.new(l(2), "+", [l(3)], infix: true)])
  it_parses %Q(#{receiver_source}call (1)),         Call.new(receiver_node, "call", [l(1)])
  it_parses %Q(
    #{receiver_source}call(
      1,
      2
    )
  ),                            Call.new(receiver_node, "call", [l(1), l(2)])
  it_parses %Q(
    #{receiver_source}call(
    )
  ),                            Call.new(receiver_node, "call")
  # Calls with parameters _must_ wrap them in parentheses.
  it_does_not_parse %Q(#{receiver_source}call a, b)

  # Blocks can be given to a Call as either brace blocks (`{}`) or `do...end` constructs.
  it_parses %Q(#{receiver_source}call{ }),     Call.new(receiver_node, "call", block: Block.new)
  it_parses %Q(#{receiver_source}call   { }),  Call.new(receiver_node, "call", block: Block.new)
  it_parses %Q(
    #{receiver_source}call do
    end
  ),                              Call.new(receiver_node, "call", block: Block.new)
  it_parses %Q(
    #{receiver_source}call    do
    end
  ),                              Call.new(receiver_node, "call", block: Block.new)

  # The `do...end` syntax can also have a delimiter after the `do` and parameters.
  it_parses %Q(#{receiver_source}call do; end),       Call.new(receiver_node, "call",   block: Block.new)
  it_parses %Q(#{receiver_source}call? do; end),      Call.new(receiver_node, "call?",  block: Block.new)
  it_parses %Q(#{receiver_source}call! do; end),      Call.new(receiver_node, "call!",  block: Block.new)
  it_parses %Q(#{receiver_source}call   do; end),     Call.new(receiver_node, "call",   block: Block.new)
  it_parses %Q(#{receiver_source}call do |a|; end),   Call.new(receiver_node, "call",   block: Block.new([p("a")]))

  # Brace blocks accept arguments after the opening brace.
  it_parses %Q(#{receiver_source}call{ |a,b| }),                  Call.new(receiver_node, "call",   block: Block.new([p("a"), p("b")]))
  it_parses %Q(#{receiver_source}call?{ |a,b| }),                 Call.new(receiver_node, "call?",  block: Block.new([p("a"), p("b")]))
  it_parses %Q(#{receiver_source}call!{ |a,b| }),                 Call.new(receiver_node, "call!",  block: Block.new([p("a"), p("b")]))
  # Block parameters are exactly like normal Def parameters, with the same syntax support.
  it_parses %Q(#{receiver_source}call{ | | }),                    Call.new(receiver_node, "call", block: Block.new())
  it_parses %Q(#{receiver_source}call{ |a,*b| }),                 Call.new(receiver_node, "call", block: Block.new([p("a"), p("b", splat: true)]))
  it_parses %Q(#{receiver_source}call{ |1,nil=:thing| }),         Call.new(receiver_node, "call", block: Block.new([p(nil, l(1)), p("thing", l(nil))]))
  it_parses %Q(#{receiver_source}call{ |a : Integer, b : Nil| }), Call.new(receiver_node, "call", block: Block.new([p("a", restriction: c("Integer")), p("b", restriction: c("Nil"))]))
  it_parses %Q(#{receiver_source}call{ |1 =: a : Integer| }),     Call.new(receiver_node, "call", block: Block.new([p("a", l(1), restriction: c("Integer"))]))
  it_parses %Q(#{receiver_source}call{ |<other>| }),              Call.new(receiver_node, "call", block: Block.new([p(nil, i(Call.new(nil, "other")))]))
  it_parses %Q(#{receiver_source}call{ |<a.b>| }),                Call.new(receiver_node, "call", block: Block.new([p(nil, i(Call.new(Call.new(nil, "a"), "b")))]))
  it_parses %Q(#{receiver_source}call{ |<a[0]>| }),               Call.new(receiver_node, "call", block: Block.new([p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])))]))
  it_parses %Q(#{receiver_source}call{ |*a,b| }),                 Call.new(receiver_node, "call", block: Block.new([p("a", splat: true), p("b")]))
  it_parses %Q(#{receiver_source}call{ |a,*b,c| }),               Call.new(receiver_node, "call", block: Block.new([p("a"), p("b", splat: true), p("c")]))
  it_parses %Q(#{receiver_source}call{ |a,&block| }),             Call.new(receiver_node, "call", block: Block.new([p("a")], block_param: p("block", block: true)))
  it_parses %Q(#{receiver_source}call{ |a,&b| }),                 Call.new(receiver_node, "call", block: Block.new([p("a")], block_param: p("b", block: true)))
  it_parses %Q(#{receiver_source}call{ |a,
                                              &b| }),                 Call.new(receiver_node, "call", block: Block.new([p("a")], block_param: p("b", block: true)))

  it_does_not_parse %Q(#{receiver_source}call{ |&b,a| }),     /block parameter/
  it_does_not_parse %Q(#{receiver_source}call{ |*a,*b| }),    /multiple splat/

  # `do...end` blocks accept arguments
  it_parses %Q(
    #{receiver_source}call do | |
    end
  ),                Call.new(receiver_node, "call", block: Block.new())
  it_parses %Q(
    #{receiver_source}call do |a,*b|
    end
  ),                Call.new(receiver_node, "call", block: Block.new([p("a"), p("b", splat: true)]))
  it_parses %Q(
    #{receiver_source}call do |*a,b|
    end
  ),                Call.new(receiver_node, "call", block: Block.new([p("a", splat: true), p("b")]))
  it_parses %Q(
    #{receiver_source}call do |a,*b,c|
    end
  ),                Call.new(receiver_node, "call", block: Block.new([p("a"), p("b", splat: true), p("c")]))
  it_parses %Q(
    #{receiver_source}call do |a,&block|
    end
  ),                Call.new(receiver_node, "call", block: Block.new([p("a")], block_param: p("block", block: true)))
  it_parses %Q(
    #{receiver_source}call do |a,&b|
    end
  ),                Call.new(receiver_node, "call", block: Block.new([p("a")], block_param: p("b", block: true)))
  it_parses %Q(
    #{receiver_source}call do |a,
              &b|
    end
  ),                Call.new(receiver_node, "call", block: Block.new([p("a")], block_param: p("b", block: true)))

  it_does_not_parse %Q(
    #{receiver_source}call do |&b,a|
    end
  ),                      /block parameter/
  it_does_not_parse %Q(
    #{receiver_source}call do |*a,*b|
    end
  ),                      /multiple splat/

  it_does_not_parse %Q(
    #{receiver_source}call{
      |arg|
    }
  )
  it_does_not_parse %Q(
    #{receiver_source}call do
      |arg|
    end
  )

  # Calls with arguments _and_ blocks provide the block after the closing parenthesis.
  it_parses %Q(#{receiver_source}call(1, 2){ }),  Call.new(receiver_node, "call", [l(1), l(2)], block: Block.new)
  it_parses %Q(
    #{receiver_source}call(1, 2) do
    end
  ),                            Call.new(receiver_node, "call", [l(1), l(2)], block: Block.new)

  # Calls with blocks that are within other calls can also accept blocks.
  it_parses %Q(call(#{receiver_source}inner(1){ })),  Call.new(nil, "call", [Call.new(receiver_node, "inner", [l(1)], block: Block.new).as(Node)])
  it_parses %Q(
    call(#{receiver_source}inner(1) do
    end)
  ),                                Call.new(nil, "call", [Call.new(receiver_node, "inner", [l(1)], block: Block.new).as(Node)])
  it_parses %Q(call(1, #{receiver_source}inner(1){ }, 2)),  Call.new(nil, "call", [l(1), Call.new(receiver_node, "inner", [l(1)], block: Block.new), l(2)])
  it_parses %Q(
    call(1, #{receiver_source}inner(1) do
    end, 2)
  ),                                      Call.new(nil, "call", [l(1), Call.new(receiver_node, "inner", [l(1)], block: Block.new), l(2)])

  # Blocks are exactly like normal defs, they can contain any valid Expressions node as a body.
  it_parses %Q(#{receiver_source}call{ a = 1; a }), Call.new(receiver_node, "call", block: Block.new(body: e(SimpleAssign.new(v("a"), l(1)), v("a"))))
  it_parses %Q(#{receiver_source}call{
      a = 1
      a
    }
  ), Call.new(receiver_node, "call", block: Block.new(body: e(SimpleAssign.new(v("a"), l(1)), v("a"))))
  it_parses %Q(#{receiver_source}call do
      a = 1
      a
    end
  ), Call.new(receiver_node, "call", block: Block.new(body: e(SimpleAssign.new(v("a"), l(1)), v("a"))))
end



describe "Parser" do
  # Empty program
  # An empty program should not contain any nodes under the root Expressions.
  it_parses %q()


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
  it_parses %q([1, *a, 3]),     l([1, Splat.new(Call.new(nil, "a")), 3])
  it_parses %q([*a, *b]),       l([Splat.new(Call.new(nil, "a")), Splat.new(Call.new(nil, "b"))])

  it_parses %q({}),             MapLiteral.new
  it_parses %q({a: 1, b: 2}),   l({ :a => 1, :b => 2 })
  it_parses %q({  a: call   }), l({ :a => Call.new(nil, "call") })
  it_parses %q(
    {
      something: "hello",
      other: 5.4
    }
  ),                            l({ :something => "hello", :other => 5.4 })

  it_parses %q(__FILE__),       MagicConst.new(:file)
  it_parses %q(__LINE__),       MagicConst.new(:line)

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
  it_parses %q(<[a, *b]>),      i(l([Call.new(nil, "a"), Splat.new(Call.new(nil, "b"))]))
  it_parses %q(<{a: 1}>),       i({:a => 1})
  # Interpolations are valid as receivers for Calls
  test_calls_with_receiver("<a>.",  i(Call.new(nil, "a")))
  # Calls, Vars, Consts, Underscores are also valid.
  it_parses %q(<a>),            i(Call.new(nil, "a"))
  it_parses %q(<a?>),           i(Call.new(nil, "a?"))
  it_parses %q(<a!>),           i(Call.new(nil, "a!"))
  it_parses %q(<a(1, 2)>),      i(Call.new(nil, "a", [l(1), l(2)]))
  it_parses %q(<a.b(1)>),       i(Call.new(Call.new(nil, "a"), "b", [l(1)]))
  it_parses %q(<a.b.c>),        i(Call.new(Call.new(Call.new(nil, "a"), "b"), "c"))
  it_parses %q(<a{ }>),         i(Call.new(nil, "a", block: Block.new))
  it_parses %q(<a do; end>),    i(Call.new(nil, "a", block: Block.new))
  it_parses %q(<Thing>),        i(c("Thing"))
  it_parses %q(<Thing.Other>),  i(Call.new(c("Thing"), "Other"))
  it_parses %q(<A.B.C>),        i(Call.new(Call.new(c("A"), "B"), "C"))
  it_parses %q(<_>),            i(u("_"))
  it_parses %q(<a[0]>),         i(Call.new(Call.new(nil, "a"), "[]", [l(0)]))
  it_parses %q(<a.b[0]>),       i(Call.new(Call.new(Call.new(nil, "a"), "b"), "[]", [l(0)]))
  it_parses %q(<[1, 2][0]>),    i(Call.new(l([1, 2]), "[]", [l(0)]))
  it_parses %q(<{a: 1}[:a]>),   i(Call.new(l({ :a => 1 }), "[]", [l(:a)]))
  it_parses %q(<a(1, 2)[0]>),   i(Call.new(Call.new(nil, "a", [l(1), l(2)]), "[]", [l(0)]))
  # Complex expressions must be wrapped in parentheses.
  it_parses %q(<(a)>),          i(Call.new(nil, "a"))
  it_parses %q(<(1 + 2)>),      i(Call.new(l(1), "+", [l(2)], infix: true))
  it_does_not_parse %q(<1 + 2>)
  it_does_not_parse %q(<a + b>)
  it_does_not_parse %q(< a + b >)
  # Spacing within the braces is not important
  it_parses %q(< a >),          i(Call.new(nil, "a"))
  it_parses %q(< a[0]   >),     i(Call.new(Call.new(nil, "a"), "[]", [l(0)]))
  # Interpolations can span multiple lines if necessary.
  it_parses %q(<
    a
  >),                           i(Call.new(nil, "a"))
  it_parses %q(<
    (1 + 2)
  >),                           i(Call.new(l(1), "+", [l(2)], infix: true))
  # Interpolations can also be used as Map keys.
  it_parses %q(
    {
      <1>: "int",
      <nil>: :nil
    }
  ),                            l({ i(1) => "int", i(nil) => :nil })
  # Interpolations can be used as a replacement for any primary expression.
  it_parses %q([1, <2>, 3]),    l([1, i(2), 3])
  it_parses %q([1, <a.b>, 3]),  l([1, i(Call.new(Call.new(nil, "a"), "b")), 3])
  it_parses %q(<a[0]> + 4),     Call.new(i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), "+", [l(4)], infix: true)



  # String Interpolations

  # Strings with interpolations are lexed as single String tokens. The parser
  # splits the string into components around `<(...)>` constructs, then parses
  # the contents of those constructs and joins them together to form a list of
  # String components consisting of StringLiterals and arbitrary Nodes.

  # Empty interpolations and string pieces should be removed, and the
  # surrounding string pieces should be merged. If the string is otherwise
  # empty, a blank string literal is used. If the remainder is a single
  # StringLiteral, it is not wrapped in an InterpolatedStringLiteral.
  it_parses %q("<()>"),                       l("")
  it_parses %q("hello<()>"),                  l("hello")
  it_parses %q("<()>, world"),                l(", world")
  it_parses %q("hello<()>, world"),           istr(l("hello"), l(", world"))
  it_parses %q("<()>hello<()>, world<()>!"),  istr(l("hello"), l(", world"), l("!"))
  # Simple expressions
  it_parses %q("<(a)>"),                      istr(Call.new(nil, "a"))
  it_parses %q("<(nil)>"),                    istr(l(nil))
  it_parses %q("<(true)>"),                   istr(l(true))
  it_parses %q("<(false)>"),                  istr(l(false))
  it_parses %q("<(1)>"),                      istr(l(1))
  it_parses %q("<(1.0)>"),                    istr(l(1.0))
  it_parses %q("<("hi")>"),                   istr(l("hi"))
  it_parses %q("<("")>"),                     istr(l(""))
  it_parses %q("<(:hi)>"),                    istr(l(:hi))
  it_parses %q("<([])>"),                     istr(ListLiteral.new)
  it_parses %q("<({})>"),                     istr(MapLiteral.new)

  # Unterminated string literals and unclosed interpolations are caught and
  # handled by the lexer. For example, the code `"<("` will raise a SyntaxError
  # before being lexed.

  # Spacing within the interpolation is not important
  it_parses %q("<(  {}  )>"),               istr(MapLiteral.new)
  it_parses %q("<(
    {}  )>"),                               istr(MapLiteral.new)
  it_parses %q("<(
    )>"),                                   l("")
  # Arbitrary newlines are also allowed, and are not included in the resulting
  # string contents.
  it_parses %q("hello<(
    ""
  )>, world"),                              istr(l("hello"), l(""), l(", world"))

  # Local variables are preserved inside the interpolation
  it_parses %q(a = 1; "<(a)>"),             SimpleAssign.new(v("a"), l(1)), istr(v("a"))

  # Complex expressions
  it_parses %q("2 is <(1 + 1)>"),           istr(l("2 is "), Call.new(l(1), "+", [l(1)], infix: true))

  # Nested interpolations
  it_parses %q("<( "<(b)>" )>"),            istr(istr(Call.new(nil, "b")))

  # Maps, brace blocks, and calls with arguments in interpolations are all
  # potentially ambiguous.
  it_parses %q("<(a.b{ |e| e*2 })>"),     istr(Call.new(Call.new(nil, "a"), "b", block: Block.new([p("e")], Call.new(v("e"), "*", [l(2)], infix: true))))
  it_parses %q("<(a.b{ |e| "<(e)>" })>"), istr(Call.new(Call.new(nil, "a"), "b", block: Block.new([p("e")], istr(v("e")))))
  it_parses %q("<({a: "<(2)>"})>"),       istr(l({:a => istr(l(2))}))
  it_parses %q("<(a.join(","))>"),        istr(Call.new(Call.new(nil, "a"), "join", [l(",")]))

  # Multiple interpolations
  it_parses %q("hello, <(first_name)> <(last_name)>"),  istr(l("hello, "), Call.new(nil, "first_name"), l(" "), Call.new(nil, "last_name"))
  it_parses %q("<(first_name)><(last_name)>"),          istr(Call.new(nil, "first_name"), Call.new(nil, "last_name"))
  it_parses %q("hello, <(first_name)>, or <(other)>"),  istr(l("hello, "), Call.new(nil, "first_name"), l(", or "), Call.new(nil, "other"))



  # Infix expressions

  it_parses %q(1 || 2),         Or.new(l(1), l(2))
  it_parses %q(1 || 2 || 3),    Or.new(l(1), Or.new(l(2), l(3)))
  it_parses %q(1 && 2),         And.new(l(1), l(2))
  it_parses %q(1 && 2 && 3),    And.new(l(1), And.new(l(2), l(3)))

  it_parses %q(1 == 2),         Call.new(l(1), "==",  [l(2)], infix: true)
  it_parses %q(1 != 2),         Call.new(l(1), "!=",  [l(2)], infix: true)
  it_parses %q(1  < 2),         Call.new(l(1), "<",   [l(2)], infix: true)
  it_parses %q(1 <= 2),         Call.new(l(1), "<=",  [l(2)], infix: true)
  it_parses %q(1 >= 2),         Call.new(l(1), ">=",  [l(2)], infix: true)
  it_parses %q(1  > 2),         Call.new(l(1), ">",   [l(2)], infix: true)


  it_parses %q(1 + 2),          Call.new(l(1), "+",   [l(2)], infix: true)
  it_parses %q(1 - 2),          Call.new(l(1), "-",   [l(2)], infix: true)
  it_parses %q(1 * 2),          Call.new(l(1), "*",   [l(2)], infix: true)
  it_parses %q(1 / 2),          Call.new(l(1), "/",   [l(2)], infix: true)
  it_parses %q(1 % 2),          Call.new(l(1), "%",   [l(2)], infix: true)
  it_parses %q("hello" * 2),    Call.new(l("hello"), "*", [l(2)], infix: true)
  it_parses %q([1] - [2]),      Call.new(l([1]), "-", [l([2])], infix: true)

  # Precedence
  it_parses %q(1 && 2 || 3),    Or.new(And.new(l(1), l(2)), l(3))
  it_parses %q(1 || 2 && 3),    Or.new(l(1), And.new(l(2), l(3)))
  it_parses %q(1 == 2 && 3),    And.new(Call.new(l(1), "==", [l(2)], infix: true).as(Node), l(3))
  it_parses %q(1 && 2 == 3),    And.new(l(1), Call.new(l(2), "==", [l(3)], infix: true))
  it_parses %q(1  < 2 == 3),    Call.new(Call.new(l(1), "<",  [l(2)], infix: true).as(Node), "==", [l(3)], infix: true)
  it_parses %q(1 == 2  < 3),    Call.new(l(1), "==", [Call.new(l(2), "<",  [l(3)], infix: true).as(Node)], infix: true)
  it_parses %q(1  + 2  < 3),    Call.new(Call.new(l(1), "+",  [l(2)], infix: true).as(Node), "<",  [l(3)], infix: true)
  it_parses %q(1  < 2  + 3),    Call.new(l(1), "<",  [Call.new(l(2), "+",  [l(3)], infix: true).as(Node)], infix: true)
  it_parses %q(1  * 2  + 3),    Call.new(Call.new(l(1), "*",  [l(2)], infix: true).as(Node), "+",  [l(3)], infix: true)
  it_parses %q(1  + 2  * 3),    Call.new(l(1), "+",  [Call.new(l(2), "*",  [l(3)], infix: true).as(Node)], infix: true)

  # Left-associativity for arithmetic expressions
  it_parses %q(1 - 1 - 1),      Call.new(Call.new(l(1), "-", [l(1)], infix: true), "-", [l(1)], infix: true)
  it_parses %q(1 + 1 - 1),      Call.new(Call.new(l(1), "+", [l(1)], infix: true), "-", [l(1)], infix: true)
  it_parses %q(1 - 1 + 1),      Call.new(Call.new(l(1), "-", [l(1)], infix: true), "+", [l(1)], infix: true)
  it_parses %q(1 / 1 / 1),      Call.new(Call.new(l(1), "/", [l(1)], infix: true), "/", [l(1)], infix: true)
  it_parses %q(1 * 1 / 1),      Call.new(Call.new(l(1), "*", [l(1)], infix: true), "/", [l(1)], infix: true)
  it_parses %q(1 / 1 * 1),      Call.new(Call.new(l(1), "/", [l(1)], infix: true), "*", [l(1)], infix: true)
  it_parses %q(1 / 1 % 1),      Call.new(Call.new(l(1), "/", [l(1)], infix: true), "%", [l(1)], infix: true)
  it_parses %q(1 % 1 / 1),      Call.new(Call.new(l(1), "%", [l(1)], infix: true), "/", [l(1)], infix: true)
  it_parses %q(1 % 1 % 1),      Call.new(Call.new(l(1), "%", [l(1)], infix: true), "%", [l(1)], infix: true)

  it_parses %q(1 * (2 || 3)),   Call.new(l(1), "*", [Or.new(l(2), l(3)).as(Node)], infix: true)

  # Ensure Calls can be used as operands to infix expressions
  it_parses %q(call + other * last), Call.new(Call.new(nil, "call"), "+", [Call.new(Call.new(nil, "other"), "*", [Call.new(nil, "last").as(Node)], infix: true).as(Node)], infix: true)



  # Unary expressions.

  # Note: these examples represent valid _syntax_. They may appear semantically
  # invalid, but should be accepted by the parser none-the-less.

  {% for op in [[:!, Not], [:-, Negation], [:*, Splat]] %}
    # Unary expressions are an operator followed by any valid postfix expression.
    it_parses %q({{op[0].id}}  nil),      {{op[1]}}.new(l(nil))
    it_parses %q({{op[0].id}}false),      {{op[1]}}.new(l(false))
    it_parses %q({{op[0].id}}"hello"),    {{op[1]}}.new(l("hello"))
    it_parses %q({{op[0].id}}[1, 2]),     {{op[1]}}.new(l([1, 2]))
    it_parses %q({{op[0].id}}{a: 2}),     {{op[1]}}.new(l({ :a => 2 }))
    it_parses %q({{op[0].id}}:hi),        {{op[1]}}.new(l(:hi))
    it_parses %q({{op[0].id}}<1.5>),      {{op[1]}}.new(i(1.5))
    it_parses %q({{op[0].id}}<other>),    {{op[1]}}.new(i(Call.new(nil, "other")))
    it_parses %q({{op[0].id}}a),          {{op[1]}}.new(Call.new(nil, "a"))
    it_parses %q({{op[0].id}}(1 + 2)),    {{op[1]}}.new(Call.new(l(1), "+", [l(2)], infix: true))
    it_parses %q({{op[0].id}}a.b),        {{op[1]}}.new(Call.new(Call.new(nil, "a"), "b"))
    it_parses %q({{op[0].id}}Thing.b),    {{op[1]}}.new(Call.new(c("Thing"), "b"))
    it_parses %q(
      {{op[0].id}}(
        1 + 2
      )
    ),                {{op[1]}}.new(Call.new(l(1), "+", [l(2)], infix: true))

    # Unary operators can be chained any number of times.
    it_parses %q({{op[0].id}}{{op[0].id}}a),              {{op[1]}}.new({{op[1]}}.new(Call.new(nil, "a")))
    it_parses %q({{op[0].id}}{{op[0].id}}{{op[0].id}}a),  {{op[1]}}.new({{op[1]}}.new({{op[1]}}.new(Call.new(nil, "a"))))

    # Unary operators are not valid without an argument.
    it_does_not_parse %q({{op[0].id}})
    # The operand must start on the same line as the operator.
    it_does_not_parse %q(
      {{op[0].id}}
      a
    )

    # Unary operations are more precedent than binary operations
    it_parses %q({{op[0].id}}1 + 2),    Call.new({{op[1]}}.new(l(1)), "+", [l(2)], infix: true)
    it_parses %q(1 + {{op[0].id}}2),    Call.new(l(1), "+", [{{op[1]}}.new(l(2)).as(Node)], infix: true)

    # Unary operations can be used anywherea primary expression is expected.
    it_parses %q([1, {{op[0].id}}a]),   l([1, {{op[1]}}.new(Call.new(nil, "a"))])
  {% end %}

  # Unary operators can also be mixed when chaining.
  it_parses %q(!*-a),     Not.new(Splat.new(Negation.new(Call.new(nil, "a"))))
  it_parses %q(-*!100),   Negation.new(Splat.new(Not.new(l(100))))
  it_parses %q(-!*[1,2]), Negation.new(Not.new(Splat.new(l([1, 2]))))

  # Unary operators have a higher precedence than any binary operation.
  it_parses %q(-1 +  -2),   Call.new(Negation.new(l(1)), "+", [Negation.new(l(2)).as(Node)], infix: true)
  it_parses %q(!1 || !2),   Or.new(Not.new(l(1)), Not.new(l(2)).as(Node))
  it_parses %q(-1 == -2),   Call.new(Negation.new(l(1)), "==", [Negation.new(l(2)).as(Node)], infix: true)
  it_parses %q( a =  -1),   SimpleAssign.new(v("a"), Negation.new(l(1)))



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
  it_parses %q(1 || b = 2 + c = 3 || 4), Or.new(l(1), SimpleAssign.new(v("b"), Call.new(l(2), "+", [SimpleAssign.new(v("c"), Or.new(l(3), l(4))).as(Node)], infix: true)))
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
  # The left hand side may also be a Call expression as long as the Call has a receiver.
  it_parses %q(a.b = 1),          Call.new(Call.new(nil, "a"), "b=", [l(1)])
  it_parses %q(a.b.c = 1),        Call.new(Call.new(Call.new(nil, "a"), "b"), "c=", [l(1)])
  it_parses %q(a[0] = 1),         Call.new(Call.new(nil, "a"), "[]=", [l(0), l(1)])
  it_parses %q(a.b = c.d = 1),    Call.new(Call.new(nil, "a"), "b=", [Call.new(Call.new(nil, "c"), "d=", [l(1)]).as(Node)])
  it_parses %q(a[0] = b[0] = 1),  Call.new(Call.new(nil, "a"), "[]=", [l(0), Call.new(Call.new(nil, "b"), "[]=", [l(0), l(1)]).as(Node)])
  # Assignments are not allowed to methods with modifiers
  it_does_not_parse %q(a.b? = 1)
  it_does_not_parse %q(a.b! = 1)

  # Assignments can not be made to literal values.
  it_does_not_parse %q(2 = 4),          /cannot assign to literal value/i
  it_does_not_parse %q(2.56 = 4),       /cannot assign to literal value/i
  it_does_not_parse %q("hi" = 4),       /cannot assign to literal value/i
  it_does_not_parse %q(nil = 4),        /cannot assign to literal value/i
  it_does_not_parse %q(false = true),   /cannot assign to literal value/i
  it_does_not_parse %q([1, 2, 3] = 4),  /cannot assign to literal value/i



  # Match Assignments

  # Match assignments allow literal values on either side
  it_parses %q(1 =: 1),             MatchAssign.new(l(1), l(1))
  it_parses %q(:hi =: "hi"),        MatchAssign.new(l(:hi), l("hi"))
  it_parses %q(true =: false),      MatchAssign.new(l(true), l(false))
  it_parses %q([1, 2] =: [1, 2]),   MatchAssign.new(l([1, 2]), l([1, 2]))
  it_parses %q({a: 2} =: {a: 2}),   MatchAssign.new(l({:a => 2}),l({:a => 2}))
  # Splats in list literals act as Splat collectors (as in Params).
  it_parses %q([1, *_, 3] =: list), MatchAssign.new(l([1, Splat.new(u("_")), 3]), Call.new(nil, "list"))
  it_parses %q([1, *a, 3] =: list), MatchAssign.new(l([1, Splat.new(v("a")), 3]), Call.new(nil, "list"))
  # Vars, Consts, and Underscores can also be used on either side.
  it_parses %q(a =: 5),             MatchAssign.new(v("a"), l(5))
  it_parses %q(Thing =: 10),        MatchAssign.new(c("Thing"), l(10))
  it_parses %q(_ =: 15),            MatchAssign.new(u("_"), l(15))
  # Value Interpolations are also allowed on either side for complex patterns/values.
  it_parses %q(<a> =: <b>),         MatchAssign.new(i(Call.new(nil, "a")), i(Call.new(nil, "b")))
  it_parses %q(<a.b> =: <c.d>),     MatchAssign.new(i(Call.new(Call.new(nil, "a"), "b")), i(Call.new(Call.new(nil, "c"), "d")))
  it_parses %q(<a[0]> =: <b[0]>),   MatchAssign.new(i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), i(Call.new(Call.new(nil, "b"), "[]", [l(0)])))
  # Bare multiple assignment is not allowed. Use a List pattern instead.
  it_does_not_parse %q(a, b =: [1, 2])
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



  # Operational Assignments

  # Most binary operations can be concatenated with an assignment to form an
  # Operational Assignment. These are a syntactic shorthand for and operation
  # and assignment on the same variable, i.e., `a op= b` is equivalent to
  # writing  `a = a op b`.
  {% for op in ["+=", "-=", "*=", "/=", "%=", "||=", "&&="] %}
    # When the left-hand-side is an identifier, treat it as a Var.
    it_parses %q(a {{op.id}} 1),              OpAssign.new(v("a"), {{op}}, l(1))
    it_parses %q(a {{op.id}} a {{op.id}} 1),  OpAssign.new(v("a"), {{op}}, OpAssign.new(v("a"), {{op}}, l(1)))
    it_parses %q(a {{op.id}} 1 + 2),          OpAssign.new(v("a"), {{op}}, Call.new(l(1), "+", [l(2)], infix: true))
    it_parses %q(a {{op.id}} Thing.member),   OpAssign.new(v("a"), {{op}}, Call.new(c("Thing"), "member"))

    # The left-hand-side can also be any simple Call
    it_parses %q(a.b {{op.id}} 1),                OpAssign.new(Call.new(Call.new(nil, "a"), "b"), {{op}}, l(1))
    it_parses %q(a.b {{op.id}} a.b {{op.id}} 1),  OpAssign.new(Call.new(Call.new(nil, "a"), "b"), {{op}}, OpAssign.new(Call.new(Call.new(nil, "a"), "b"), {{op}}, l(1)))
    it_parses %q(a.b {{op.id}} 1 + 2),            OpAssign.new(Call.new(Call.new(nil, "a"), "b"), {{op}}, Call.new(l(1), "+", [l(2)], infix: true))
    it_parses %q(a.b {{op.id}} Thing.member),     OpAssign.new(Call.new(Call.new(nil, "a"), "b"), {{op}}, Call.new(c("Thing"), "member"))
    it_parses %q(a[0] {{op.id}} 1),                 OpAssign.new(Call.new(Call.new(nil, "a"), "[]", [l(0)]), {{op}}, l(1))
    it_parses %q(a[0] {{op.id}} a[0] {{op.id}} 1),  OpAssign.new(Call.new(Call.new(nil, "a"), "[]", [l(0)]), {{op}}, OpAssign.new(Call.new(Call.new(nil, "a"), "[]", [l(0)]), {{op}}, l(1)))
    it_parses %q(a[0] {{op.id}} 1 + 2),             OpAssign.new(Call.new(Call.new(nil, "a"), "[]", [l(0)]), {{op}}, Call.new(l(1), "+", [l(2)], infix: true))
    it_parses %q(a[0] {{op.id}} Thing.member),      OpAssign.new(Call.new(Call.new(nil, "a"), "[]", [l(0)]), {{op}}, Call.new(c("Thing"), "member"))

    # As an infix expression, the value can appear on a new line
    it_parses %q(
      a.b {{op.id}}
        1 + 2
    ),              OpAssign.new(Call.new(Call.new(nil, "a"), "b"), {{op}}, Call.new(l(1), "+", [l(2)], infix: true))
    it_parses %q(
      a.b {{op.id}} (1 +
        2
      )
    ),              OpAssign.new(Call.new(Call.new(nil, "a"), "b"), {{op}}, Call.new(l(1), "+", [l(2)], infix: true))

    # The left-hand-side must be an assignable value (i.e., not a literal)
    it_does_not_parse %q(1 {{op.id}} 2)
    it_does_not_parse %q(nil {{op.id}} 2)
    it_does_not_parse %q([1, 2] {{op.id}} 2)
    # No left-hand-side is also invalid
    it_does_not_parse %q({{op.id}} 2)
  {% end %}


  # Element access

  # The List notation `[...]` is used on any object to access specific
  # elements within it.
  it_parses %q(list[1]),      Call.new(Call.new(nil, "list"), "[]", [l(1)])
  it_parses %q(list[a]),      Call.new(Call.new(nil, "list"), "[]", [Call.new(nil, "a").as(Node)])
  it_parses %q(list[Thing]),  Call.new(Call.new(nil, "list"), "[]", [c("Thing").as(Node)])
  it_parses %q(list[1 + 2]),  Call.new(Call.new(nil, "list"), "[]", [Call.new(l(1), "+", [l(2)], infix: true).as(Node)])
  it_parses %q(list[a = 1]),  Call.new(Call.new(nil, "list"), "[]", [SimpleAssign.new(v("a"), l(1)).as(Node)])
  it_parses %q(list[a = 1]),  Call.new(Call.new(nil, "list"), "[]", [SimpleAssign.new(v("a"), l(1)).as(Node)])
  it_parses %q(list["hi"]),   Call.new(Call.new(nil, "list"), "[]", [l("hi")])
  it_parses %q(list[:hello]), Call.new(Call.new(nil, "list"), "[]", [l(:hello)])
  # Accesses can accept any number of arguments, of any type.
  it_parses %q(list[1, 2]),         Call.new(Call.new(nil, "list"), "[]", [l(1), l(2)])
  it_parses %q(list[nil, false]),   Call.new(Call.new(nil, "list"), "[]", [l(nil), l(false)])
  # The receiver can be any expression.
  it_parses %q((1 + 2)[0]),   Call.new(Call.new(l(1), "+", [l(2)], infix: true), "[]", [l(0)])
  it_parses %q((a = 1)[0]),   Call.new(SimpleAssign.new(v("a"), l(1)), "[]", [l(0)])
  it_parses %q(false[0]),     Call.new(l(false), "[]", [l(0)])
  it_parses %q("hello"[0]),   Call.new(l("hello"), "[]", [l(0)])
  it_parses %q([1, 2][0]),    Call.new(l([1, 2]), "[]", [l(0)])
  it_parses %q({a: 1}[0]),    Call.new(l({ :a => 1 }), "[]", [l(0)])
  it_parses %q(a.b[0]),       Call.new(Call.new(Call.new(nil, "a"), "b"), "[]", [l(0)])
  it_parses %q(Thing.a[0]),   Call.new(Call.new(c("Thing"), "a"), "[]", [l(0)])
  it_parses %q(a(1, 2)[0]),   Call.new(Call.new(nil, "a", [l(1), l(2)]), "[]", [l(0)])
  it_parses %q(
    map{ }[0]
  ),            Call.new(Call.new(nil, "map", block: Block.new), "[]", [l(0)])
  it_parses %q(
    map do
    end[0]
  ),            Call.new(Call.new(nil, "map", block: Block.new), "[]", [l(0)])
  # Accesses must start on the same line, but can span multiple after the opening brace.
  it_parses %q(
    list[
      1,
      2
    ]
  ),            Call.new(Call.new(nil, "list"), "[]", [l(1), l(2)])
  it_parses %q(
    list[
      1 + 2
    ]
  ),            Call.new(Call.new(nil, "list"), "[]", [Call.new(l(1), "+", [l(2)], infix: true).as(Node)])
  it_parses %q(
    list
    [1, 2]
  ),            Call.new(nil, "list"), l([1, 2])
  it_parses %q(
    [1, 2]
    [0]
  ),            l([1, 2]), l([0])
  # Accesses can also be chained together
  it_parses %q(list[1][2]),  Call.new(Call.new(Call.new(nil, "list"), "[]", [l(1)]), "[]", [l(2)])

  # The List notation must have at least one argument to be valid
  it_does_not_parse %q(list[])




  # Expression delimiters

  # Newlines can be used to delimit complete expressions
  it_parses %q(
    a = 1
    a + 2
  ),              SimpleAssign.new(v("a"), l(1)), Call.new(v("a"), "+", [l(2)], infix: true)
  it_parses %q(
    nil
    [4, 5]
  ),              l(nil), l([4, 5])
  # Semicolons can also be used to place multiple expressions on a single line
  it_parses %q(
    a = 1; a + 2;
    b = 2;
  ),              SimpleAssign.new(v("a"), l(1)), Call.new(v("a"), "+", [l(2)], infix: true), SimpleAssign.new(v("b"), l(2))
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
  ),              Call.new(Call.new(nil, "var1"), "+", [Call.new(nil, "var2").as(Node)], infix: true)
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

  # Any identifier is valid as a definition name
  it_parses %q(def foo_;  end), Def.new("foo_")
  it_parses %q(def _foo;  end), Def.new("_foo")
  it_parses %q(def foo?;  end), Def.new("foo?")
  it_parses %q(def foo!;  end), Def.new("foo!")
  it_parses %q(def foo_!; end), Def.new("foo_!")
  it_parses %q(def foo_?; end), Def.new("foo_?")

  # `=` can also be appended to any non-modified identifier.
  it_parses %q(def foo=;    end), Def.new("foo=")
  it_parses %q(def foo_=(); end), Def.new("foo_=")
  it_parses %q(def _foo=(); end), Def.new("_foo=")
  # Multiple modifiers are not allowed
  it_does_not_parse %q(def foo?=; end)
  it_does_not_parse %q(def foo!=; end)


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
  ),            Def.new("foo", body: e(Call.new(l(1), "+", [l(2)], infix: true)))

  it_parses %q(
    def foo
      a = 1
      a * 4
    end
  ),            Def.new("foo", body: e(SimpleAssign.new(v("a"), l(1)), Call.new(v("a"), "*", [l(4)], infix: true)))

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
  it_parses %q(def foo(<a.b> =: _); end),   Def.new("foo", [p("_", i(Call.new(Call.new(nil, "a"), "b")))])
  it_parses %q(def foo(<a[0]> =: _); end),  Def.new("foo", [p("_", i(Call.new(Call.new(nil, "a"), "[]", [l(0)])))])
  # Splats within patterns are allowed.
  it_parses %q(def foo([1, *_, 3]); end),   Def.new("foo", [p(nil, l([1, Splat.new(u("_")), 3]))])

  # Type restrictions can be appended to any parameter to restrict the parameter
  # to an exact type. The type must be a constant.
  # Simple names
  it_parses %q(def foo(a : Integer); end),          Def.new("foo", [p("a", restriction: c("Integer"))])
  it_parses %q(def foo(a : Nil); end),              Def.new("foo", [p("a", restriction: c("Nil"))])
  it_parses %q(def foo(a : Thing); end),            Def.new("foo", [p("a", restriction: c("Thing"))])
  it_does_not_parse %q(def foo(a : 123); end)
  it_does_not_parse %q(def foo(a : nil); end)
  it_does_not_parse %q(def foo(a : [1, 2]); end)
  it_does_not_parse %q(def foo(a : b); end)
  it_does_not_parse %q(def foo(a : 1 + 2); end)
  it_does_not_parse %q(def foo(a : <thing>); end)
  it_does_not_parse %q(def foo(a : (A + B)); end)
  # Simple patterns
  it_parses %q(def foo(1 : Integer); end),        Def.new("foo", [p(nil, l(1), restriction: c("Integer"))])
  it_parses %q(def foo(1 : Nil); end),            Def.new("foo", [p(nil, l(1), restriction: c("Nil"))])
  it_parses %q(def foo(1 : Thing); end),          Def.new("foo", [p(nil, l(1), restriction: c("Thing"))])
  it_parses %q(def foo(nil : Integer); end),      Def.new("foo", [p(nil, l(nil), restriction: c("Integer"))])
  it_parses %q(def foo(nil : Nil); end),          Def.new("foo", [p(nil, l(nil), restriction: c("Nil"))])
  it_parses %q(def foo(nil : Thing); end),        Def.new("foo", [p(nil, l(nil), restriction: c("Thing"))])
  it_parses %q(def foo(<call> : Integer); end),   Def.new("foo", [p(nil, i(Call.new(nil, "call")), restriction: c("Integer"))])
  it_parses %q(def foo(<call> : Nil); end),       Def.new("foo", [p(nil, i(Call.new(nil, "call")), restriction: c("Nil"))])
  it_parses %q(def foo(<call> : Thing); end),     Def.new("foo", [p(nil, i(Call.new(nil, "call")), restriction: c("Thing"))])
  it_parses %q(def foo(<a.b> : Integer); end),    Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Integer"))])
  it_parses %q(def foo(<a.b> : Nil); end),        Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Nil"))])
  it_parses %q(def foo(<a.b> : Thing); end),      Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Thing"))])
  it_parses %q(def foo(<a[0]> : Integer); end),   Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Integer"))])
  it_parses %q(def foo(<a[0]> : Nil); end),       Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Nil"))])
  it_parses %q(def foo(<a[0]> : Thing); end),     Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Thing"))])
  it_parses %q(def foo([1, 2] : Integer); end),   Def.new("foo", [p(nil, l([1, 2]), restriction: c("Integer"))])
  it_parses %q(def foo([1, 2] : Nil); end),       Def.new("foo", [p(nil, l([1, 2]), restriction: c("Nil"))])
  it_parses %q(def foo([1, 2] : Thing); end),     Def.new("foo", [p(nil, l([1, 2]), restriction: c("Thing"))])
  # Patterns and names
  it_parses %q(def foo(1 =: a : Integer); end),       Def.new("foo", [p("a", l(1), restriction: c("Integer"))])
  it_parses %q(def foo(1 =: a : Nil); end),           Def.new("foo", [p("a", l(1), restriction: c("Nil"))])
  it_parses %q(def foo(1 =: a : Thing); end),         Def.new("foo", [p("a", l(1), restriction: c("Thing"))])
  it_parses %q(def foo(nil =: a : Integer); end),     Def.new("foo", [p("a", l(nil), restriction: c("Integer"))])
  it_parses %q(def foo(nil =: a : Nil); end),         Def.new("foo", [p("a", l(nil), restriction: c("Nil"))])
  it_parses %q(def foo(nil =: a : Thing); end),       Def.new("foo", [p("a", l(nil), restriction: c("Thing"))])
  it_parses %q(def foo(<call> =: a : Integer); end),  Def.new("foo", [p("a", i(Call.new(nil, "call")), restriction: c("Integer"))])
  it_parses %q(def foo(<call> =: a : Nil); end),      Def.new("foo", [p("a", i(Call.new(nil, "call")), restriction: c("Nil"))])
  it_parses %q(def foo(<call> =: a : Thing); end),    Def.new("foo", [p("a", i(Call.new(nil, "call")), restriction: c("Thing"))])
  it_parses %q(def foo(<a.b> : Integer); end),        Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Integer"))])
  it_parses %q(def foo(<a.b> : Nil); end),            Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Nil"))])
  it_parses %q(def foo(<a.b> : Thing); end),          Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Thing"))])
  it_parses %q(def foo(<a[0]> : Integer); end),       Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Integer"))])
  it_parses %q(def foo(<a[0]> : Nil); end),           Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Nil"))])
  it_parses %q(def foo(<a[0]> : Thing); end),         Def.new("foo", [p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Thing"))])
  it_parses %q(def foo([1, 2] =: a : Integer); end),  Def.new("foo", [p("a", l([1, 2]), restriction: c("Integer"))])
  it_parses %q(def foo([1, 2] =: a : Nil); end),      Def.new("foo", [p("a", l([1, 2]), restriction: c("Nil"))])
  it_parses %q(def foo([1, 2] =: a : Thing); end),    Def.new("foo", [p("a", l([1, 2]), restriction: c("Thing"))])
  # Only the top level parameters may have retrictions.
  it_does_not_parse %q(def foo([1, a : List]); end)
  it_does_not_parse %q(def foo([1, _ : List]); end)
  it_does_not_parse %q(def foo([1, [a, b] : List]); end)
  it_does_not_parse %q(def foo([1, a : List] =: c); end)
  it_does_not_parse %q(def foo([1, _ : List] =: c); end)
  it_does_not_parse %q(def foo([1, [a, b] : List] =: c); end)
  # Block and Splat parameters may not have restrictions
  it_does_not_parse %q(def foo(*a : List); end)
  it_does_not_parse %q(def foo(&block : Block); end)
  # All components of a parameter must appear inline with the previous component
  it_does_not_parse %q(
    def foo(a :
                List)
  )
  it_does_not_parse %q(
    def foo(a
              : List)
  )
  it_does_not_parse %q(
    def foo(<(1+2)> =:
                        a)
  )
  it_does_not_parse %q(
    def foo(<(1+2)>
                    =: a)
  )
  # Individual components of a parameter _may_ span multiple lines, but should
  # avoid it where possible.
  it_parses %q(
    def foo(<(1 +
                  2)> =: a : Integer); end
  ),                                    Def.new("foo", [p("a", i(Call.new(l(1), "+", [l(2)], infix: true)), restriction: c("Integer"))])
  # Parameters may each appear on their own line for clarity
  it_parses %q(
    def foo(
        [1, _] =: list : List,
        nil,
        b : Integer
      )
    end
  ),                            Def.new("foo", [p("list", l([1, u("_")]), restriction: c("List")), p(nil, l(nil)), p("b", restriction: c("Integer"))])

  # Some operators are also allowed as method names for overloading.
  [
    "+", "-", "*", "/", "%", "[]", "[]=",
    "<", "<=", "!=", "==", ">=", ">"
  ].each do |op|
    it_parses %Q(def #{op}; end),         Def.new(op)
    it_parses %Q(def #{op}(); end),       Def.new(op)
    it_parses %Q(def #{op}(other); end),  Def.new(op, [p("other")])
    it_parses %Q(def #{op}(a, b); end),   Def.new(op, [p("a"), p("b")])
  end


  # Module definitions

  it_parses %q(
    defmodule Foo
    end
  ),                                  ModuleDef.new("Foo")
  it_parses %q(defmodule Foo; end),   ModuleDef.new("Foo")
  # Modules must specify a Constant as their name
  it_does_not_parse %q(defmodule foo; end)
  it_does_not_parse %q(defmodule _nope; end)
  it_parses %q(
    defmodule Foo
      def foo; end
    end
  ),                ModuleDef.new("Foo", e(Def.new("foo")))
  # Modules allow immediate code evaluation on their scope.
  it_parses %q(
    defmodule Foo
      1 + 2
      a = 3
    end
  ),                ModuleDef.new("Foo", e(Call.new(l(1), "+", [l(2)], infix: true), SimpleAssign.new(v("a"), l(3))))
  # Modules can also be nested
  it_parses %q(
    defmodule Foo
      defmodule Bar
      end
    end
  ),                ModuleDef.new("Foo", e(ModuleDef.new("Bar")))



  # Type definitions

  # A type definition can contain 0 or more properties
  it_parses %q(
    deftype Thing
    end
  ),                                  TypeDef.new("Thing")
  it_parses %q(deftype Thing; end),   TypeDef.new("Thing")
  # Types must specify a Constant as their name
  it_does_not_parse %q(deftype foo; end)
  it_does_not_parse %q(deftype _nope; end)

  # Types allow immediate code evaluation on their scope.
  it_parses %q(
    deftype Thing
      1 + 2
      a = 3
    end
  ),                TypeDef.new("Thing", body: e(Call.new(l(1), "+", [l(2)], infix: true), SimpleAssign.new(v("a"), l(3))))

  # Types can also be nested
  it_parses %q(
    deftype Thing
      deftype Part
      end
    end
  ),                TypeDef.new("Thing", body: e(TypeDef.new("Part")))


  # Type methods

  it_parses %q(
    deftype Foo
      def foo; end
    end
  ),                TypeDef.new("Foo", body: e(Def.new("foo")))

  it_parses %q(
    deftype Foo
      defstatic foo; end
    end
  ),                TypeDef.new("Foo", body: e(Def.new("foo", static: true)))

  # Types and modules can be arbitrarily nested.
  it_parses %q(
    deftype Foo
      defmodule Bar
        deftype Baz
        end
      end
    end
  ),                    TypeDef.new("Foo", body: e(ModuleDef.new("Bar", e(TypeDef.new("Baz")))))
  it_parses %q(
    defmodule Foo
      deftype Bar
        defmodule Baz
        end
      end
    end
  ),                    ModuleDef.new("Foo", e(TypeDef.new("Bar", body: e(ModuleDef.new("Baz")))))



  # Instance variables

  # Instance variables are marked with an `@` prefix.
  it_parses %q(@a),           iv("a")
  it_parses %q(@variable),    iv("variable")
  # Instance variables can appear as a primary value anywhere they are accepted.
  it_parses %q(<@var>),       i(iv("var"))
  it_parses %q(1 + @var),     Call.new(l(1), "+", [iv("var")] of Node, infix: true)
  it_parses %q(@var.each),    Call.new(iv("var"), "each")
  it_parses %q(
    def foo(<@var>)
    end
  ),                          Def.new("foo", [p(nil, i(iv("var")))])

  # Instance variables can be the target of any assignment.
  it_parses %q(@var = 1),           SimpleAssign.new(iv("var"), l(1))
  it_parses %q([1, @a] =: [1, 2]),  MatchAssign.new(l([1, iv("a")]), l([1, 2]))
  it_parses %q(@var ||= {}),        OpAssign.new(iv("var"), "||=", MapLiteral.new)



  # Type initialization

  # Instances of types are created with a percent characeter and brace syntax
  # akin to blocks.
  it_parses %q(%Thing{}),           Instantiation.new(c("Thing"))
  it_parses %q(%Thing {}),          Instantiation.new(c("Thing"))
  it_parses %q(%Thing   {   }),     Instantiation.new(c("Thing"))
  it_parses %q(%Thing{ 1 }),        Instantiation.new(c("Thing"), [l(1)])
  it_parses %q(%Thing{ 1, 2, 3 }),  Instantiation.new(c("Thing"), [l(1), l(2), l(3)])
  it_parses %q(%Thing{ [nil, 1] }), Instantiation.new(c("Thing"), [l([nil, 1])])
  it_parses %q(%Thing{1}),          Instantiation.new(c("Thing"), [l(1)])
  it_parses %q(%Thing{1, 2, 3}),    Instantiation.new(c("Thing"), [l(1), l(2), l(3)])
  it_parses %q(%Thing{[nil, 1]}),   Instantiation.new(c("Thing"), [l([nil, 1])])
  it_parses %q(%Thing{
    1
  }),          Instantiation.new(c("Thing"), [l(1)])
  it_parses %q(%Thing{
    1, 2, 3
  }),    Instantiation.new(c("Thing"), [l(1), l(2), l(3)])
  it_parses %q(%Thing{
    [nil, 1]
  }),   Instantiation.new(c("Thing"), [l([nil, 1])])

  # The braces are required for initialization, even when there are no arguments.
  it_does_not_parse %q(%Thing)
  # There must not be spaces between the percent and the type name
  it_does_not_parse %q(%  Thing{   })
  it_does_not_parse %q(%  Thing { })
  # Similarly, the brace must appear inline  with the type.
  it_does_not_parse %q(
    %Thing
    {}
  )

  # The type can be either a Const or an interpolation. Any interpolation is
  # valid, and may span multiple lines.
  it_parses %q(%<thing>{}),             Instantiation.new(i(Call.new(nil, "thing")))
  it_parses %q(%<@type>{}),             Instantiation.new(i(iv("type")))
  it_parses %q(%<1.type>{}),            Instantiation.new(i(Call.new(l(1), "type")))
  it_parses %q(%<(type || Default)>{}), Instantiation.new(i(Or.new(Call.new(nil, "type"), c("Default"))))
  it_parses %q(
    %<(
      type
    )>{}
  ),                                    Instantiation.new(i(Call.new(nil, "type")))

  # Any other node is invalid as a type specification.
  it_does_not_parse %q(%nil{})
  it_does_not_parse %q(%false{})
  it_does_not_parse %q(%1{})
  it_does_not_parse %q(%"hello"{})
  it_does_not_parse %q(%some_type{})

  # Initializations are similar to Calls, allowing all the same syntax for the arguments, including blocks.
  it_parses %q(%Thing{ *opts }),        Instantiation.new(c("Thing"), [Splat.new(Call.new(nil, "opts"))] of Node)
  it_parses %q(%Thing{ } do; end),      Instantiation.new(c("Thing"), block: Block.new)
  it_parses %q(%Thing{ } { }),          Instantiation.new(c("Thing"), block: Block.new)
  it_parses %q(
    %Thing{ } do |a,b|
    end
  ),                      Instantiation.new(c("Thing"), block: Block.new([p("a"), p("b")]))
  it_parses %q(
    %Thing{ } { |a,b| }
  ),                      Instantiation.new(c("Thing"), block: Block.new([p("a"), p("b")]))

  # Also as in a Call, trailing commas and the like are invalid
  it_does_not_parse %q(%Thing{ 1, })
  it_does_not_parse %q(%Thing{
    1,
  })



  # Calls

  test_calls_with_receiver("",                  nil)
  test_calls_with_receiver("object.",           Call.new(nil, "object"))
  test_calls_with_receiver("object?.",          Call.new(nil, "object?"))
  test_calls_with_receiver("object!.",          Call.new(nil, "object!"))
  test_calls_with_receiver("nested.object.",    Call.new(Call.new(nil, "nested"), "object"))
  test_calls_with_receiver("Thing.member.",     Call.new(c("Thing"), "member"))
  test_calls_with_receiver("Thing.Other.",      Call.new(c("Thing"), "Other"))
  test_calls_with_receiver("1.",                l(1))
  test_calls_with_receiver("[1, 2, 3].",        l([1, 2, 3]))
  test_calls_with_receiver("list[1].",          Call.new(Call.new(nil, "list"), "[]", [l(1)]))
  test_calls_with_receiver("list[1, 2].",       Call.new(Call.new(nil, "list"), "[]", [l(1), l(2)]))
  test_calls_with_receiver(%q("some string".),  l("some string"))
  test_calls_with_receiver("(1 + 2).",          Call.new(l(1), "+", [l(2)], infix: true))
  test_calls_with_receiver("method{ }.",        Call.new(nil, "method", block: Block.new))
  test_calls_with_receiver("method do; end.",   Call.new(nil, "method", block: Block.new))
  test_calls_with_receiver("@var.",             iv("var"))
  test_calls_with_receiver("%Thing{}.",         Instantiation.new(c("Thing")))



  # Self

  # `self` can be used anywhere a primary expression is allowed
  it_parses %q(self),                 Self.new
  it_parses %q(-self),                Negation.new(Self.new)
  it_parses %q(<self>),               i(Self.new)
  it_parses %q(self + self),          Call.new(Self.new, "+", [Self.new.as(Node)], infix: true)
  test_calls_with_receiver("self.",   Self.new)
  it_parses %q(self[0]),              Call.new(Self.new, "[]", [l(0)])
  # `self` can not be used as the name of a Call
  it_does_not_parse %q(object.self)



  # Include

  # Includes accept any node as an argument, and are valid in any context.
  it_parses %q(include Thing),        Include.new(c("Thing"))
  it_parses %q(include Thing.Other),  Include.new(Call.new(c("Thing"), "Other"))
  it_parses %q(include dynamic),      Include.new(Call.new(nil, "dynamic"))
  it_parses %q(include 1 + 2),        Include.new(Call.new(l(1), "+", [l(2)], infix: true))
  it_parses %q(include self),         Include.new(Self.new)
  it_parses %q(include <something>),  Include.new(i(Call.new(nil, "something")))
  it_parses %q(
    defmodule Thing
      include Other
    end
  ),                                  ModuleDef.new("Thing", e(Include.new(c("Other"))))
  it_parses %q(
    def foo
      include Thing
    end
  ),                                  Def.new("foo", body: e(Include.new(c("Thing"))))
  # The argument for an include must be on the same line as the keyword
  it_does_not_parse %q(
    include
    Thing
  ),                      /expected value for include/
  # The argument is still allowed to span multiple lines
  it_parses %q(
    include 1 +
            2
  ),                                  Include.new(Call.new(l(1), "+", [l(2)], infix: true))
  # Only one value is expected. Providing multiple values is invalid.
  it_does_not_parse %q(
    include Thing1, Thing2
  )



  # Require

  # Requires are syntactically similar to includes, but the expected value is a String.
  it_parses %q(require "some_file"),  Require.new(l("some_file"))
  it_parses %q(require base + path),  Require.new(Call.new(Call.new(nil, "base"), "+", [Call.new(nil, "path").as(Node)], infix: true))
  it_parses %q(require Thing.dep),    Require.new(Call.new(c("Thing"), "dep"))
  it_parses %q(require <something>),  Require.new(i(Call.new(nil, "something")))
  it_parses %q(
    defmodule Thing
      require "other_thing"
    end
  ),                                  ModuleDef.new("Thing", e(Require.new(l("other_thing"))))
  it_parses %q(
    def foo
      require "other_thing"
    end
  ),                                  Def.new("foo", body: e(Require.new(l("other_thing"))))
  it_does_not_parse %q(
    require
    "some_file"
  ),                      /expected value for require/
  it_parses %q(
    require base +
            path
  ),                                  Require.new(Call.new(Call.new(nil, "base"), "+", [Call.new(nil, "path").as(Node)], infix: true))
  # Only one value is expected. Providing multiple values is invalid.
  it_does_not_parse %q(
    require "file1", "file2"
  )



  # Conditionals

  # The primary conditional expression is `when`. It functionally replaces `if`
  # from most other languages.
  it_parses %q(
    when true
    end
  ),                                When.new(l(true))
  it_parses %q(when true; end),     When.new(l(true))
  it_parses %q(when a == 1; end),   When.new(Call.new(Call.new(nil, "a"), "==", [l(1)], infix: true))
  # Any expression can be used as a condition
  it_parses %q(
    when a = 1
    end
  ),                                When.new(SimpleAssign.new(v("a"), l(1)))
  it_parses %q(
    when 1 + 2
    end
  ),                                When.new(Call.new(l(1), "+", [l(2)], infix: true))
  it_parses %q(
    when call(1, 2)
    end
  ),                                When.new(Call.new(nil, "call", [l(1), l(2)]))
  it_parses %q(
    when [1,2].map{ |e| }
    end
  ),                                When.new(Call.new(l([1, 2]), "map", block: Block.new([p("e")])))
  # The body of a When is a normal code block.
  it_parses %q(
    when true
      1 + 1
      do_something
    end
  ),                                When.new(l(true), e(Call.new(l(1), "+", [l(1)], infix: true), Call.new(nil, "do_something")))
  # Whens can be chained together for more complex logic. This is most similar
  # to `else if` in other languages.
  it_parses %q(
    when true
      # Do a thing
    when false
      # Do another thing
    end
  ),                                When.new(l(true), alternative: When.new(l(false)))
  # An `else` can be used at the end of a When chain as a catch-all.
  it_parses %q(
    when true
    else
      a = 1
    end
  ),                                When.new(l(true), alternative: e(SimpleAssign.new(v("a"), l(1))))
  it_parses %q(
    when true
    when false
    else
    end
  ),                                When.new(l(true), alternative: When.new(l(false)))
  # Whens are also valid as the value of an assignment
  it_parses %q(
    a = when true
        when false
        end
  ),                                SimpleAssign.new(v("a"), When.new(l(true), alternative: When.new(l(false))))
  it_parses %q(
    long_name =
      when true
      when false
      end
  ),                                SimpleAssign.new(v("long_name"), When.new(l(true), alternative: When.new(l(false))))
  # Only one expression may be given for the condition of a When
  it_does_not_parse %q(
    when a, b
    end
  )


  # Unless is the logical inverse of When.
  it_parses %q(
    unless true
    end
  ),                                Unless.new(l(true))
  it_parses %q(unless true; end),   Unless.new(l(true))
  it_parses %q(unless a == 1; end), Unless.new(Call.new(Call.new(nil, "a"), "==", [l(1)], infix: true))
  it_parses %q(
    unless a = 1
    end
  ),                                Unless.new(SimpleAssign.new(v("a"), l(1)))
  it_parses %q(
    unless 1 + 2
    end
  ),                                Unless.new(Call.new(l(1), "+", [l(2)], infix: true))
  it_parses %q(
    unless call(1, 2)
    end
  ),                                Unless.new(Call.new(nil, "call", [l(1), l(2)]))
  it_parses %q(
    unless [1,2].map{ |e| }
    end
  ),                                Unless.new(Call.new(l([1, 2]), "map", block: Block.new([p("e")])))
  it_parses %q(
    unless true
      1 + 1
      do_something
    end
  ),                                Unless.new(l(true), e(Call.new(l(1), "+", [l(1)], infix: true), Call.new(nil, "do_something")))
  it_parses %q(
    unless true
      # Do a thing
    unless false
      # Do another thing
    end
  ),                                Unless.new(l(true), alternative: Unless.new(l(false)))
  it_parses %q(
    unless true
    else
    end
  ),                                Unless.new(l(true))
  it_parses %q(
    unless true
    else
      a = 1
    end
  ),                                Unless.new(l(true), alternative: e(SimpleAssign.new(v("a"), l(1))))
  it_parses %q(
    unless true
    unless false
    else
    end
  ),                                Unless.new(l(true), alternative: Unless.new(l(false)))
  it_parses %q(
    a = unless true
        unless false
        end
  ),                                SimpleAssign.new(v("a"), Unless.new(l(true), alternative: Unless.new(l(false))))
  it_parses %q(
    long_name =
      unless true
      unless false
      end
  ),                                SimpleAssign.new(v("long_name"), Unless.new(l(true), alternative: Unless.new(l(false))))

  # When and Unless can be used in any combination
  it_parses %q(
    when true
    unless false
    end
  ),                                When.new(l(true), alternative: Unless.new(l(false)))
  it_parses %q(
    unless false
    when true
    end
  ),                                Unless.new(l(false), alternative: When.new(l(true)))
  it_parses %q(
    when true
    unless false
    when true
    end
  ),                                When.new(l(true), alternative: Unless.new(l(false), alternative: When.new(l(true))))
  it_parses %q(
    unless false
    when true
    unless false
    end
  ),                                Unless.new(l(false), alternative: When.new(l(true), alternative: Unless.new(l(false))))
  it_parses %q(
    a = when true
        unless false
        end
  ),                                SimpleAssign.new(v("a"), When.new(l(true), alternative: Unless.new(l(false))))
  it_parses %q(
    long_name =
      unless true
      when false
      end
  ),                                SimpleAssign.new(v("long_name"), Unless.new(l(true), alternative: When.new(l(false))))


  # `else` _must_ be the last block of a When chain
  it_does_not_parse %q(
    when true
    else
    when false
    end
  )
  it_does_not_parse %q(
    unless true
    else
    unless false
    end
  )
  # `else` is not valid on it's own
  it_does_not_parse %q(else; end)
  it_does_not_parse %q(
    else
    end
  )

  # Whens cannot be directly nested. These fail because the Whens are
  # considered as a single chain, so the second end is unexpected.
  it_does_not_parse %q(
    when true
      when false
      end
    end
  )
  it_does_not_parse %q(
    unless true
      unless false
      end
    end
  )

  # Whens that are nested within other constructs maintain their scoping
  it_parses %q(
    when true
      call do
        when true
        else
        end
      end
    when false
    end
  )



  # Loops

  # Loops are syntactically similar to Whens, but do not allow for chaining.
  # While and Until are the main looping constructs.
  it_parses %q(
    while true
    end
  ),                                While.new(l(true))
  it_parses %q(while true; end),    While.new(l(true))
  it_parses %q(while a == 1; end),  While.new(Call.new(Call.new(nil, "a"), "==", [l(1)], infix: true))
  it_parses %q(
    while a = 1
    end
  ),                                While.new(SimpleAssign.new(v("a"), l(1)))
  it_parses %q(
    while 1 + 2
    end
  ),                                While.new(Call.new(l(1), "+", [l(2)], infix: true))
  it_parses %q(
    while call(1, 2)
    end
  ),                                While.new(Call.new(nil, "call", [l(1), l(2)]))
  it_parses %q(
    while [1,2].map{ |e| }
    end
  ),                                While.new(Call.new(l([1, 2]), "map", block: Block.new([p("e")])))
  it_parses %q(
    while true
      1 + 1
      do_something
    end
  ),                                While.new(l(true), e(Call.new(l(1), "+", [l(1)], infix: true), Call.new(nil, "do_something")))

  it_parses %q(
    until true
    end
  ),                                Until.new(l(true))
  it_parses %q(until true; end),    Until.new(l(true))
  it_parses %q(until a == 1; end),  Until.new(Call.new(Call.new(nil, "a"), "==", [l(1)], infix: true))
  it_parses %q(
    until a = 1
    end
  ),                                Until.new(SimpleAssign.new(v("a"), l(1)))
  it_parses %q(
    until 1 + 2
    end
  ),                                Until.new(Call.new(l(1), "+", [l(2)], infix: true))
  it_parses %q(
    until call(1, 2)
    end
  ),                                Until.new(Call.new(nil, "call", [l(1), l(2)]))
  it_parses %q(
    until [1,2].map{ |e| }
    end
  ),                                Until.new(Call.new(l([1, 2]), "map", block: Block.new([p("e")])))
  it_parses %q(
    until true
      1 + 1
      do_something
    end
  ),                                Until.new(l(true), e(Call.new(l(1), "+", [l(1)], infix: true), Call.new(nil, "do_something")))

  # Loops can be nested directly
  it_parses %q(
    while true
      until false
      end
    end
  ),                                While.new(l(true), e(Until.new(l(false))))
  it_parses %q(
    until false
      while true
      end
    end
  ),                                Until.new(l(false), e(While.new(l(true))))

  # Loops and conditionals can be intertwined with no issues.
  it_parses %q(
    while true
      when a == b
      end
    end
  ),                                While.new(l(true), e(When.new(Call.new(Call.new(nil, "a"), "==", [Call.new(nil, "b").as(Node)], infix: true))))



  # Flow Control

  # Returns, Breaks, and Nexts all accept an optional value, like other keyword
  # expressions, the value must start on the same line as the keyword.

  {% for keyword, node in { "return".id => Return, "break".id => Break, "next".id => Next } %}
    it_parses %q({{keyword}}),              {{node}}.new
    it_parses %q({{keyword}} nil),          {{node}}.new(l(nil))
    it_parses %q({{keyword}} 1),            {{node}}.new(l(1))
    it_parses %q({{keyword}} "hello"),      {{node}}.new(l("hello"))
    it_parses %q({{keyword}} {a: 1, b: 2}), {{node}}.new(l({ :a => 1, :b => 2 }))
    it_parses %q({{keyword}} [1, 2, 3]),    {{node}}.new(l([1, 2, 3]))
    it_parses %q({{keyword}} %Thing{}),     {{node}}.new(Instantiation.new(c("Thing")))
    it_parses %q({{keyword}} Const),        {{node}}.new(c("Const"))
    it_parses %q({{keyword}} a),            {{node}}.new(Call.new(nil, "a"))
    it_parses %q({{keyword}} 1 + 2),        {{node}}.new(Call.new(l(1), "+", [l(2)], infix: true))
    it_parses %q({{keyword}} *collection),  {{node}}.new(Splat.new(Call.new(nil, "collection")))
    it_parses %q(
      {{keyword}} 1 +
                  2
    ),                                      {{node}}.new(Call.new(l(1), "+", [l(2)], infix: true))
    it_parses %q(
      {{keyword}} (
        1 + 2
      )
    ),                                      {{node}}.new(Call.new(l(1), "+", [l(2)], infix: true))
    it_parses %q(
      {{keyword}}
      1 + 2
    ),                                      {{node}}.new, Call.new(l(1), "+", [l(2)], infix: true)

    # Carrying multiple values implicitly is not supported. To simulate this,
    # use a List instead.
    it_does_not_parse %q(
      {{keyword}} 1, 2
    )
  {% end %}



  # Raise

  # A Raise is syntactically valid so long as it is given an argument.
  it_parses %q(raise "hello"),  Raise.new(l("hello"))
  it_parses %q(raise :hi),      Raise.new(l(:hi))
  it_parses %q(raise nil),      Raise.new(l(nil))
  it_parses %q(raise true),     Raise.new(l(true))
  it_parses %q(raise false),    Raise.new(l(false))
  it_parses %q(raise 1),        Raise.new(l(1))
  it_parses %q(raise 1.0),      Raise.new(l(1))
  it_parses %q(raise []),       Raise.new(ListLiteral.new)
  it_parses %q(raise {}),       Raise.new(MapLiteral.new)
  it_parses %q(raise Thing),    Raise.new(c("Thing"))
  it_parses %q(raise a),        Raise.new(Call.new(nil, "a"))
  it_parses %q(raise a.b),      Raise.new(Call.new(Call.new(nil, "a"), "b"))
  it_parses %q(raise 1 + 2),    Raise.new(Call.new(l(1), "+", [l(2)], infix: true))
  it_parses %q(raise %Thing{}), Raise.new(Instantiation.new(c("Thing")))
  it_parses %q(raise <[1, 2]>), Raise.new(i(l([1, 2])))
  it_does_not_parse %q(raise),  /value/

  # The argument to the raise must start on the same line as the keyword
  it_does_not_parse %q(
    raise
      "some error"
  ),                            /value/

  # A Raise is _not_ a normal Call, and thus does not accept multiple parameters or a block.
  it_does_not_parse %q(raise 1, 2)
  it_does_not_parse %q(raise do; end)
  it_does_not_parse %q(raise { |a| })



  # Exception Handling

  # Exceptions can be handled and dealt with by any combination of `rescue` and
  # optionally plus `else` and/or `ensure` clauses.
  # These clauses are only valid when they trail either a Def or Block.
  it_parses %q(
    def foo
    rescue
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new]))
  it_parses %q(def foo; rescue; end), Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new]))
  # The trailing clauses may contain any valid Expressions node.
  it_parses %q(
    def foo
    rescue
      1 + 2
      a = 1
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(e(Call.new(l(1), "+", [l(2)], infix: true), SimpleAssign.new(v("a"), l(1))))]))
  it_parses %q(def foo; rescue; a; end), Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(e(Call.new(nil, "a")))]))

  # `rescue` can also accept a single Param (with the same syntax as Def) to restrict what Exceptions it can handle.
  it_parses %q(
    def foo
    rescue nil
    end),           Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l(nil)))]))
  it_parses %q(
    def foo
    rescue [1, a]
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l([1, v("a")])))]))
  it_parses %q(
    def foo
    rescue {a: 1, b: b}
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l({ :a => 1, :b => v("b") })))]))
  # Patterns can also be followed by a name to capture the entire argument.
  it_parses %q(
    def foo
    rescue [1, a] =: b
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("b", l([1, v("a")])))]))
  it_parses %q(
    def foo
    rescue <other> =: _
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("_", i(Call.new(nil, "other"))))]))

  # Splats within patterns are allowed.
  it_parses %q(
    def foo
    rescue [1, *_, 3]
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l([1, Splat.new(u("_")), 3])))]))

  # Type restrictions can be appended to any parameter to restrict the parameter
  # to an exact type. The type must be a constant.
  it_parses %q(
    def foo
    rescue a : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", restriction: c("Integer")))]))
  it_does_not_parse %q(
    def foo
    rescue a : 123
    end
  )
  it_does_not_parse %q(
    def foo
    rescue a : nil
    end
  )
  it_does_not_parse %q(
    def foo
    rescue a : [1, 2]
    end
  )
  it_does_not_parse %q(
    def foo
    rescue a : b
    end
  )
  it_does_not_parse %q(
    def foo
    rescue a : 1 + 2
    end
  )
  it_does_not_parse %q(
    def foo
    rescue a : <thing>
    end
  )
  it_does_not_parse %q(
    def foo
    rescue a : (A + B)
    end
  )
  # Simple patterns
  it_parses %q(
    def foo
    rescue 1 : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l(1), restriction: c("Integer")))]))
  it_parses %q(
    def foo
    rescue nil : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l(nil), restriction: c("Integer")))]))
  it_parses %q(
    def foo
    rescue <call> : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(nil, "call")), restriction: c("Integer")))]))
  it_parses %q(
    def foo
    rescue <a.b> : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Integer")))]))
  it_parses %q(
    def foo
    rescue <a[0]> : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Integer")))]))
  it_parses %q(
    def foo
    rescue [1, 2] : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l([1, 2]), restriction: c("Integer")))]))
  # Patterns and names
  it_parses %q(
    def foo
    rescue 1 =: a : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(1), restriction: c("Integer")))]))
  it_parses %q(
    def foo
    rescue 1 =: a : Nil
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(1), restriction: c("Nil")))]))
  it_parses %q(
    def foo
    rescue 1 =: a : Thing
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(1), restriction: c("Thing")))]))
  it_parses %q(
    def foo
    rescue nil =: a : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(nil), restriction: c("Integer")))]))
  it_parses %q(
    def foo
    rescue nil =: a : Nil
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(nil), restriction: c("Nil")))]))
  it_parses %q(
    def foo
    rescue nil =: a : Thing
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(nil), restriction: c("Thing")))]))
  it_parses %q(
    def foo
    rescue <call> =: a : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", i(Call.new(nil, "call")), restriction: c("Integer")))]))
  it_parses %q(
    def foo
    rescue <call> =: a : Nil
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", i(Call.new(nil, "call")), restriction: c("Nil")))]))
  it_parses %q(
    def foo
    rescue <call> =: a : Thing
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", i(Call.new(nil, "call")), restriction: c("Thing")))]))
  it_parses %q(
    def foo
    rescue <a.b> : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Integer")))]))
  it_parses %q(
    def foo
    rescue <a.b> : Nil
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Nil")))]))
  it_parses %q(
    def foo
    rescue <a.b> : Thing
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Thing")))]))
  it_parses %q(
    def foo
    rescue <a[0]> : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Integer")))]))
  it_parses %q(
    def foo
    rescue <a[0]> : Nil
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Nil")))]))
  it_parses %q(
    def foo
    rescue <a[0]> : Thing
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Thing")))]))
  it_parses %q(
    def foo
    rescue [1, 2] =: a : Integer
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l([1, 2]), restriction: c("Integer")))]))
  it_parses %q(
    def foo
    rescue [1, 2] =: a : Nil
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l([1, 2]), restriction: c("Nil")))]))
  it_parses %q(
    def foo
    rescue [1, 2] =: a : Thing
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l([1, 2]), restriction: c("Thing")))]))
  # Only the top level parameters may have retrictions.
  it_does_not_parse %q(
    def foo
    rescue [1, a : List]
    end
  )
  it_does_not_parse %q(
    def foo
    rescue [1, _ : List]
    end
  )
  it_does_not_parse %q(
    def foo
    rescue [1, [a, b] : List]
    end
  )
  it_does_not_parse %q(
    def foo
    rescue [1, a : List] =: c
    end
  )
  it_does_not_parse %q(
    def foo
    rescue [1, _ : List] =: c
    end
  )
  it_does_not_parse %q(
    def foo
    rescue [1, [a, b] : List] =: c
    end
  )
  # Block and Splat parameters may not have restrictions
  it_does_not_parse %q(
    def foo
    rescue *a : List
    end
  )
  it_does_not_parse %q(
    def foo
    rescue &block : Block
    end
  )
  # All components of a parameter must appear inline with the previous component
  it_does_not_parse %q(
    def foo
    rescue a :
                List
    end
  )
  it_does_not_parse %q(
    def foo
    rescue a
              : List
    end
  )
  it_does_not_parse %q(
    def foo
    rescue <(1+2)> =:
                        a
    end
  )
  it_does_not_parse %q(
    def foo
    rescue <(1+2)>
                    =: a
    end
  )
  # Individual components of a parameter _may_ span multiple lines, but should
  # avoid it where possible.
  it_parses %q(
    def foo
    rescue <(1 +
                  2)> =: a : Integer
    end
  ),                                    Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", i(Call.new(l(1), "+", [l(2)], infix: true)), restriction: c("Integer")))]))


  # Multiple `rescue` clauses can be specified.
  it_parses %q(
    def foo
    rescue
    rescue
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new, Rescue.new]))

  it_parses %q(
    def foo
    rescue Error1
    rescue Error2
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, c("Error1"))), Rescue.new(Nop.new, p(nil, c("Error2")))]))

  it_parses %q(
    def foo
    rescue {msg: msg} : Error
    rescue Error2
    rescue
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l({:msg => v("msg")}), restriction: c("Error"))), Rescue.new(Nop.new, p(nil, c("Error2"))), Rescue.new]))

  # `ensure` can be used on its own or after a `rescue`.
  it_parses %q(
    def foo
    ensure
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, ensure: Nop.new))
  it_parses %q(
    def foo
    rescue
    ensure
    end
  ),                Def.new("foo", body: ExceptionHandler.new(Nop.new, [Rescue.new], ensure: Nop.new))

  # `ensure` _must_ be the last clause of an ExceptionHandler.
  it_does_not_parse %q(
    def foo
    ensure
    rescue
    end
  ),                /ensure/
  it_does_not_parse %q(
    def foo
    rescue
    ensure
    rescue
    end
  ),                /ensure/
  # Only 1 `ensure` clause may be given
  it_does_not_parse %q(
    def foo
    ensure
    ensure
    end
  ),                /ensure/

  # `ensure` does not take any arguments
  it_does_not_parse %q(
    def foo
    ensure x
    end
  )
  it_does_not_parse %q(
    def foo
    ensure [1, 2] =: a
    end
  )
  it_does_not_parse %q(
    def foo
    ensure ex : Exception
    end
  )

  # All forms of exception handling are also valid on Blocks defined with the `do...end` syntax.
  it_parses %q(
    each do
    rescue
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new])))
  it_parses %q(each do; rescue; end), Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new])))
  # The trailing clauses may contain any valid Expressions node.
  it_parses %q(
    each do
    rescue
      1 + 2
      a = 1
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(e(Call.new(l(1), "+", [l(2)], infix: true), SimpleAssign.new(v("a"), l(1))))])))
  it_parses %q(each do; rescue; a; end), Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(e(Call.new(nil, "a")))])))

  # `rescue` can also accept a single Param (with the same syntax as Def) to restrict what Exceptions it can handle.
  it_parses %q(
    each do
    rescue nil
    end),           Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l(nil)))])))
  it_parses %q(
    each do
    rescue [1, a]
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l([1, v("a")])))])))
  it_parses %q(
    each do
    rescue {a: 1, b: b}
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l({ :a => 1, :b => v("b") })))])))
  # Patterns can also be followed by a name to capture the entire argument.
  it_parses %q(
    each do
    rescue [1, a] =: b
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("b", l([1, v("a")])))])))
  it_parses %q(
    each do
    rescue <other> =: _
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("_", i(Call.new(nil, "other"))))])))

  # Splats within patterns are allowed.
  it_parses %q(
    each do
    rescue [1, *_, 3]
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l([1, Splat.new(u("_")), 3])))])))

  # Type restrictions can be appended to any parameter to restrict the parameter
  # to an exact type. The type must be a constant.
  it_parses %q(
    each do
    rescue a : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", restriction: c("Integer")))])))
  it_does_not_parse %q(
    each do
    rescue a : 123
    end
  )
  it_does_not_parse %q(
    each do
    rescue a : nil
    end
  )
  it_does_not_parse %q(
    each do
    rescue a : [1, 2]
    end
  )
  it_does_not_parse %q(
    each do
    rescue a : b
    end
  )
  it_does_not_parse %q(
    each do
    rescue a : 1 + 2
    end
  )
  it_does_not_parse %q(
    each do
    rescue a : <thing>
    end
  )
  it_does_not_parse %q(
    each do
    rescue a : (A + B)
    end
  )
  # Simple patterns
  it_parses %q(
    each do
    rescue 1 : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l(1), restriction: c("Integer")))])))
  it_parses %q(
    each do
    rescue nil : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l(nil), restriction: c("Integer")))])))
  it_parses %q(
    each do
    rescue <call> : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(nil, "call")), restriction: c("Integer")))])))
  it_parses %q(
    each do
    rescue <a.b> : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Integer")))])))
  it_parses %q(
    each do
    rescue <a[0]> : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Integer")))])))
  it_parses %q(
    each do
    rescue [1, 2] : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l([1, 2]), restriction: c("Integer")))])))
  # Patterns and names
  it_parses %q(
    each do
    rescue 1 =: a : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(1), restriction: c("Integer")))])))
  it_parses %q(
    each do
    rescue 1 =: a : Nil
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(1), restriction: c("Nil")))])))
  it_parses %q(
    each do
    rescue 1 =: a : Thing
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(1), restriction: c("Thing")))])))
  it_parses %q(
    each do
    rescue nil =: a : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(nil), restriction: c("Integer")))])))
  it_parses %q(
    each do
    rescue nil =: a : Nil
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(nil), restriction: c("Nil")))])))
  it_parses %q(
    each do
    rescue nil =: a : Thing
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l(nil), restriction: c("Thing")))])))
  it_parses %q(
    each do
    rescue <call> =: a : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", i(Call.new(nil, "call")), restriction: c("Integer")))])))
  it_parses %q(
    each do
    rescue <call> =: a : Nil
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", i(Call.new(nil, "call")), restriction: c("Nil")))])))
  it_parses %q(
    each do
    rescue <call> =: a : Thing
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", i(Call.new(nil, "call")), restriction: c("Thing")))])))
  it_parses %q(
    each do
    rescue <a.b> : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Integer")))])))
  it_parses %q(
    each do
    rescue <a.b> : Nil
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Nil")))])))
  it_parses %q(
    each do
    rescue <a.b> : Thing
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "b")), restriction: c("Thing")))])))
  it_parses %q(
    each do
    rescue <a[0]> : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Integer")))])))
  it_parses %q(
    each do
    rescue <a[0]> : Nil
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Nil")))])))
  it_parses %q(
    each do
    rescue <a[0]> : Thing
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, i(Call.new(Call.new(nil, "a"), "[]", [l(0)])), restriction: c("Thing")))])))
  it_parses %q(
    each do
    rescue [1, 2] =: a : Integer
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l([1, 2]), restriction: c("Integer")))])))
  it_parses %q(
    each do
    rescue [1, 2] =: a : Nil
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l([1, 2]), restriction: c("Nil")))])))
  it_parses %q(
    each do
    rescue [1, 2] =: a : Thing
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", l([1, 2]), restriction: c("Thing")))])))
  # Only the top level parameters may have retrictions.
  it_does_not_parse %q(
    each do
    rescue [1, a : List]
    end
  )
  it_does_not_parse %q(
    each do
    rescue [1, _ : List]
    end
  )
  it_does_not_parse %q(
    each do
    rescue [1, [a, b] : List]
    end
  )
  it_does_not_parse %q(
    each do
    rescue [1, a : List] =: c
    end
  )
  it_does_not_parse %q(
    each do
    rescue [1, _ : List] =: c
    end
  )
  it_does_not_parse %q(
    each do
    rescue [1, [a, b] : List] =: c
    end
  )
  # Block and Splat parameters may not have restrictions
  it_does_not_parse %q(
    each do
    rescue *a : List
    end
  )
  it_does_not_parse %q(
    each do
    rescue &block : Block
    end
  )
  # All components of a parameter must appear inline with the previous component
  it_does_not_parse %q(
    each do
    rescue a :
                List
    end
  )
  it_does_not_parse %q(
    each do
    rescue a
              : List
    end
  )
  it_does_not_parse %q(
    each do
    rescue <(1+2)> =:
                        a
    end
  )
  it_does_not_parse %q(
    each do
    rescue <(1+2)>
                    =: a
    end
  )
  # Individual components of a parameter _may_ span multiple lines, but should
  # avoid it where possible.
  it_parses %q(
    each do
    rescue <(1 +
                  2)> =: a : Integer
    end
  ),                                    Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p("a", i(Call.new(l(1), "+", [l(2)], infix: true)), restriction: c("Integer")))])))


  # Multiple `rescue` clauses can be specified.
  it_parses %q(
    each do
    rescue
    rescue
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new, Rescue.new])))

  it_parses %q(
    each do
    rescue Error1
    rescue Error2
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, c("Error1"))), Rescue.new(Nop.new, p(nil, c("Error2")))])))

  it_parses %q(
    each do
    rescue {msg: msg} : Error
    rescue Error2
    rescue
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new(Nop.new, p(nil, l({:msg => v("msg")}), restriction: c("Error"))), Rescue.new(Nop.new, p(nil, c("Error2"))), Rescue.new])))

  # `ensure` can be used on its own or after a `rescue`.
  it_parses %q(
    each do
    ensure
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, ensure: Nop.new)))
  it_parses %q(
    each do
    rescue
    ensure
    end
  ),                Call.new(nil, "each", block: Block.new(body: ExceptionHandler.new(Nop.new, [Rescue.new], ensure: Nop.new)))

  # `ensure` _must_ be the last clause of an ExceptionHandler.
  it_does_not_parse %q(
    each do
    ensure
    rescue
    end
  ),                /ensure/
  it_does_not_parse %q(
    each do
    rescue
    ensure
    rescue
    end
  ),                /ensure/
  # Only 1 `ensure` clause may be given
  it_does_not_parse %q(
    each do
    ensure
    ensure
    end
  ),                /ensure/

  # `ensure` does not take any arguments
  it_does_not_parse %q(
    each do
    ensure x
    end
  )
  it_does_not_parse %q(
    each do
    ensure [1, 2] =: a
    end
  )
  it_does_not_parse %q(
    each do
    ensure ex : Exception
    end
  )

  # Blocks using the brace syntax do _not_ allow for exception handling.
  it_does_not_parse %q(
    each {
    rescue
      # woops
    }
  )

  it_does_not_parse %q(
    each {
    ensure
      # still wrong
    }
  )



  # Anonymous functions

  # Anonymous functions are shorthand wrappers for multi-clause functions with no name. They
  # are created with an `fn ... end` block, where each clause is indicated by a "stab" (`->`),
  # followed by parenthesized parameters (even when no parameters are given), and then a block
  # for the body (either brace-block or do-end-block style).
  it_parses %q(
    fn
      ->() { }
    end
  ),                          AnonymousFunction.new([Block.new])
  it_parses %q(
    fn
      ->() do
      end
    end
  ),                          AnonymousFunction.new([Block.new(style: :doend)])

  it_parses %q(
    fn
      ->(a, b) { a + b }
    end
  ),                          AnonymousFunction.new([Block.new([p("a"), p("b")], e(Call.new(v("a"), "+", [v("b")] of Node)))])
  it_parses %q(
    fn
      ->(a, b) do
        a + b
      end
    end
  ),                          AnonymousFunction.new([Block.new([p("a"), p("b")], e(Call.new(v("a"), "+", [v("b")] of Node)), style: :doend)])

  it_parses %q(
    fn
      ->(1, :hi) { true || false }
    end
  ),                        AnonymousFunction.new([Block.new([p(nil, l(1)), p(nil, l(:hi))], e(Or.new(l(true), l(false))))])


  # The bodies of each clause may contain multiple expressions
  it_parses %q(
    fn
      ->(1, :hi) { 1 + 1; 2 + 2; }
    end
  ),                        AnonymousFunction.new([Block.new([p(nil, l(1)), p(nil, l(:hi))], e(Call.new(l(1), "+", [l(1)]), Call.new(l(2), "+", [l(2)])))])
  it_parses %q(
    fn
      ->(1, :hi) do
        1 + 1
        2 + 2
      end
    end
  ),                        AnonymousFunction.new([Block.new([p(nil, l(1)), p(nil, l(:hi))], e(Call.new(l(1), "+", [l(1)]), Call.new(l(2), "+", [l(2)])), style: :doend)])

  # Multiple clauses can be given in a row.
  it_parses %q(
    fn
      ->(a) { }
      ->(b) { }
    end
  ),                        AnonymousFunction.new([Block.new([p("a")]), Block.new([p("b")])])

  # Blank lines between clauses are also allowed
  it_parses %q(
    fn
      ->(a) { }


      ->(b) { }
    end
  ),                        AnonymousFunction.new([Block.new([p("a")]), Block.new([p("b")])])

  # Bracing styles can be mixed in the same definition.
  it_parses %q(
    fn
      ->() { }
      ->() do
      end
    end
  ),                        AnonymousFunction.new([Block.new, Block.new(style: :doend)])

  # The parameter syntax is just like normal functions. Pattern matching and all.
  it_parses %q(
    fn
      ->([a, *_, b] =: p, &block) { }
    end
  ),                       AnonymousFunction.new([Block.new([p("p", l([v("a"), Splat.new(u("_")), v("b")])), p("block", block: true)])])

  # Anonymous functions can be compacted to a single line if desired. This syntax
  # is generally unnecessary, since the normal block syntax is clearner and
  # shorter for single clauses anyway.
  it_parses %q(fn ->()  {}    end), AnonymousFunction.new([Block.new])
  it_parses %q(fn ->(a) { 1 } end), AnonymousFunction.new([Block.new([p("a")], e(l(1)))])

  # It is invalid for an anonymous function to contain less than 1 clause.
  it_does_not_parse %q(fn end),   /no clause/
  it_does_not_parse %q(
    fn
    end
  ),                              /no clause/

  # All clauses must include parentheses, even if no parameters are given
  it_does_not_parse %q(
    fn
      -> {}
    end
  )
  it_does_not_parse %q(
    fn
      -> do
      end
    end
  )

  # The parentheses for a clause must start on the same line as the stab, but are
  # allowed to span multiple lines.
  it_does_not_parse %q(
    fn
      ->
        () { }
    end
  )

  it_parses %q(
    fn
      ->(
        a,
        c
      ) { }
    end
  ),              AnonymousFunction.new([Block.new([p("a"), p("b")])])

  # Similarly, the start of the block must appear on the same line as the closing
  # parenthesis of the parameter list.
  it_does_not_parse %q(
    fn
      -> ()
        { }
    end
  )
  it_does_not_parse %q(
    fn
      -> ()
        do
      end
    end
  )

  # All clauses must have their bodies wrapped with a bracing construct, even for
  # single-expression bodies.
  it_does_not_parse %q(
    fn
      ->(a) a + 1
    end
  )
  it_does_not_parse %q(
    fn
      ->(1) { 1 }
      ->(a) a + 1
    end
  )
end
