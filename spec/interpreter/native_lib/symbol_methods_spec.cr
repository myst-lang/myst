require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - Symbol Methods" do
  describe "#to_s" do
    it_interprets %q(:hello.to_s),            [val("hello")]
    it_interprets %q(:"with spaces".to_s),    [val("with spaces")]
    it_interprets %q(:"with\nnewlines".to_s), [val("with\nnewlines")]
  end


  describe "#==" do
    it_interprets %q(:hi      == :hi),      [val(true)]
    it_interprets %q(:hello   == :hello),   [val(true)]
    it_interprets %q(:""      == :hello),   [val(false)]
    it_interprets %q(:hello   == :""),      [val(false)]

    # Quoting should not affect the equality of symbols
    it_interprets %q(:"hello" == :hello),   [val(true)]
    it_interprets %q(:hello   == :"hello"), [val(true)]

    it_interprets %q(:"hello world"   == :helloworld),  [val(false)]

    it_interprets %q(:hello  == nil),       [val(false)]
    it_interprets %q(:hello  == true),      [val(false)]
    it_interprets %q(:hello  == false),     [val(false)]
    it_interprets %q(:hello  == 0),         [val(false)]
    it_interprets %q(:hello  == 1),         [val(false)]
    it_interprets %q(:hello  == 0.0),       [val(false)]
    it_interprets %q(:hello  == 1.0),       [val(false)]
    it_interprets %q(:hello  == "hello"),   [val(false)]
    it_interprets %q(:hello  == []),        [val(false)]
    it_interprets %q(:hello  == [1, 2]),    [val(false)]
    it_interprets %q(:hello  == {}),        [val(false)]
    it_interprets %q(:hello  == {a: 1}),    [val(false)]

    it_interprets %q(:""  == nil),        [val(false)]
    it_interprets %q(:""  == true),       [val(false)]
    it_interprets %q(:""  == false),      [val(false)]
    it_interprets %q(:""  == 0),          [val(false)]
    it_interprets %q(:""  == 1),          [val(false)]
    it_interprets %q(:""  == 0.0),        [val(false)]
    it_interprets %q(:""  == 1.0),        [val(false)]
    it_interprets %q(:""  == ""),         [val(false)]
    it_interprets %q(:""  == []),         [val(false)]
    it_interprets %q(:""  == [1, 2]),     [val(false)]
    it_interprets %q(:""  == {}),         [val(false)]
    it_interprets %q(:""  == {a: 1}),     [val(false)]
  end

  describe "#!=" do
    it_interprets %q(:hi      != :hi),      [val(false)]
    it_interprets %q(:hello   != :hello),   [val(false)]
    it_interprets %q(:""      != :hello),   [val(true)]
    it_interprets %q(:hello   != :""),      [val(true)]

    # Quoting should not affect the equality of symbols
    it_interprets %q(:"hello" != :hello),   [val(false)]
    it_interprets %q(:hello   != :"hello"), [val(false)]

    it_interprets %q(:"hello world"   != :helloworld),  [val(true)]

    it_interprets %q(:hello  != nil),       [val(true)]
    it_interprets %q(:hello  != true),      [val(true)]
    it_interprets %q(:hello  != false),     [val(true)]
    it_interprets %q(:hello  != 0),         [val(true)]
    it_interprets %q(:hello  != 1),         [val(true)]
    it_interprets %q(:hello  != 0.0),       [val(true)]
    it_interprets %q(:hello  != 1.0),       [val(true)]
    it_interprets %q(:hello  != "hello"),   [val(true)]
    it_interprets %q(:hello  != []),        [val(true)]
    it_interprets %q(:hello  != [1, 2]),    [val(true)]
    it_interprets %q(:hello  != {}),        [val(true)]
    it_interprets %q(:hello  != {a: 1}),    [val(true)]

    it_interprets %q(:""  != nil),        [val(true)]
    it_interprets %q(:""  != true),       [val(true)]
    it_interprets %q(:""  != false),      [val(true)]
    it_interprets %q(:""  != 0),          [val(true)]
    it_interprets %q(:""  != 1),          [val(true)]
    it_interprets %q(:""  != 0.0),        [val(true)]
    it_interprets %q(:""  != 1.0),        [val(true)]
    it_interprets %q(:""  != ""),         [val(true)]
    it_interprets %q(:""  != []),         [val(true)]
    it_interprets %q(:""  != [1, 2]),     [val(true)]
    it_interprets %q(:""  != {}),         [val(true)]
    it_interprets %q(:""  != {a: 1}),     [val(true)]
  end
end
