require "../helper.cr"

describe "Printer - Def" do
  # TODO: Uncomment when Printer::Config is implemented.
  # %w[def defstatic].each do |def_style|
  #   # Basic parameters
  #   assert_print %Q(#{def_style} foo\nend)
  #   assert_print %Q(#{def_style} foo()\nend), %Q(#{def_style} foo\nend)
  #   assert_print %Q(#{def_style} foo(a)\nend)
  #   assert_print %Q(#{def_style} foo(a, b)\nend)
  #   assert_print %Q(#{def_style} foo(a, b, c, d, e, f, g, h, i)\nend)
  #   assert_print %Q(#{def_style} foo(_a, _b)\nend)
  #   assert_print %Q(#{def_style} foo(a, _b)\nend)

  #   # Splats
  #   assert_print %Q(#{def_style} foo(*a)\nend)
  #   assert_print %Q(#{def_style} foo(*a, b)\nend)
  #   assert_print %Q(#{def_style} foo(a, *b)\nend)
  #   assert_print %Q(#{def_style} foo(a, *b, c)\nend)

  #   # Blocks
  #   assert_print %Q(#{def_style} foo(&block)\nend)
  #   assert_print %Q(#{def_style} foo(a, &block)\nend)
  #   assert_print %Q(#{def_style} foo(a, *b, &block)\nend)
  #   assert_print %Q(#{def_style} foo(a, _, &b)\nend)
  #   assert_print %Q(#{def_style} foo(a, b, &_)\nend)

  #   # Patterns
  #   assert_print %Q(#{def_style} foo(nil)\nend)
  #   assert_print %Q(#{def_style} foo(1, 2)\nend)
  #   assert_print %Q(#{def_style} foo([1, a])\nend)
  #   assert_print %Q(#{def_style} foo({a: 1, b: b})\nend)
  #   assert_print %Q(#{def_style} foo([1, *_, 3])\nend)
  #   assert_print %Q(#{def_style} foo(Thing)\nend)
  #   assert_print %Q(#{def_style} foo(Thing, Another)\nend)
  #   assert_print %Q(#{def_style} foo("hello")\nend)
  #   assert_print %Q(#{def_style} foo(:hi, nil, false)\nend)

  #   # Patterns + names
  #   assert_print %Q(#{def_style} foo([1, a] =: b)\nend)
  #   assert_print %Q(#{def_style} foo([1, _] =: _)\nend)
  #   assert_print %Q(#{def_style} foo(<other> =: _)\nend)
  #   assert_print %Q(#{def_style} foo(<a.b> =: _)\nend)
  #   assert_print %Q(#{def_style} foo(<a[0]> =: _)\nend)

  #   # Names + type restrictions
  #   assert_print %Q(#{def_style} foo(a : Integer)\nend)

  #   # Patterns + type restrictions
  #   assert_print %Q(#{def_style} foo(1 : Integer, nil : Nil)\nend)
  #   assert_print %Q(#{def_style} foo(<call> : Symbol, <a.b> : Float, <a[0]> : Integer)\nend)
  #   assert_print %Q(#{def_style} foo([1, 2] : List, *rest, &block)\nend)

  #   # Patterns + names + type restrictions
  #   assert_print %Q(#{def_style} foo(1 =: a : Integer)\nend)
  #   assert_print %Q(#{def_style} foo(1.0 =: a : Float, "hi" =: a : String, &callback)\nend)
  #   assert_print %Q(#{def_style} foo(<call> =: a : Map, <a.b> : CustomType)\nend)
  #   assert_print %Q(#{def_style} foo(<a[0]> : Integer)\nend)
  #   assert_print %Q(#{def_style} foo([1, 2] =: list : List, *rest, {a: 1} =: map : Map)\nend)
  # end

  # TODO: support semi-colon delimiting (e.g., `def foo; end`).
end
