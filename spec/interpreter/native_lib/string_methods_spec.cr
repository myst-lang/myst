require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - String Methods" do
  describe "#+" do
    it_interprets %q("hello" + ", world"),  [val("hello, world")]
    it_interprets %q("hello\n" + "world"),  [val("hello\nworld")]

    # Arguments to `+` must already be a String. Other types are invalid.
    it_does_not_interpret %q("abc" + 123),    /invalid argument/
    it_does_not_interpret %q("abc" + 1.0),    /invalid argument/
    it_does_not_interpret %q("abc" + nil),    /invalid argument/
    it_does_not_interpret %q("abc" + false),  /invalid argument/
    it_does_not_interpret %q("abc" + :hi),    /invalid argument/
    it_does_not_interpret %q("abc" + []),     /invalid argument/
    it_does_not_interpret %q("abc" + {}),     /invalid argument/

    # Other types can be concatenated using `.to_s` on them.
    it_interprets %q("abc" + 123.to_s),  [val("abc123")]
  end

  describe "#*" do
    it_interprets %q("hi" * 3),  [val("hihihi")]

    # Only integers are allowed as an argument
    it_does_not_interpret %q("abc" * 1.0),    /invalid argument/
    it_does_not_interpret %q("abc" * nil),    /invalid argument/
    it_does_not_interpret %q("abc" * false),  /invalid argument/
    it_does_not_interpret %q("abc" * "hi"),   /invalid argument/
    it_does_not_interpret %q("abc" * :hi),    /invalid argument/
    it_does_not_interpret %q("abc" * []),     /invalid argument/
    it_does_not_interpret %q("abc" * {}),     /invalid argument/
  end


  describe "#to_s" do
    it_interprets %q("hello".to_s),   [val("hello")]
    it_interprets %q("".to_s),        [val("")]
    it_interprets %q("\n\t".to_s),    [val("\n\t")]
  end


  describe "#==" do
    it_interprets %q(""       == ""),       [val(true)]
    it_interprets %q("hello"  == "hello"),  [val(true)]
    it_interprets %q(""       == "hello"),  [val(false)]
    it_interprets %q("hello"  == ""),       [val(false)]
    it_interprets %q("\0"     == ""),       [val(false)]

    it_interprets %q("hello world"  == "helloworld"),  [val(false)]

    it_interprets %q("hello"  == nil),      [val(false)]
    it_interprets %q("hello"  == true),     [val(false)]
    it_interprets %q("hello"  == false),    [val(false)]
    it_interprets %q("hello"  == 0),        [val(false)]
    it_interprets %q("hello"  == 1),        [val(false)]
    it_interprets %q("hello"  == 0.0),      [val(false)]
    it_interprets %q("hello"  == 1.0),      [val(false)]
    it_interprets %q("hello"  == :hi),      [val(false)]
    it_interprets %q("hello"  == []),       [val(false)]
    it_interprets %q("hello"  == [1, 2]),   [val(false)]
    it_interprets %q("hello"  == {}),       [val(false)]
    it_interprets %q("hello"  == {a: 1}),   [val(false)]

    it_interprets %q(""  == nil),      [val(false)]
    it_interprets %q(""  == true),     [val(false)]
    it_interprets %q(""  == false),    [val(false)]
    it_interprets %q(""  == 0),        [val(false)]
    it_interprets %q(""  == 1),        [val(false)]
    it_interprets %q(""  == 0.0),      [val(false)]
    it_interprets %q(""  == 1.0),      [val(false)]
    it_interprets %q(""  == :hi),      [val(false)]
    it_interprets %q(""  == []),       [val(false)]
    it_interprets %q(""  == [1, 2]),   [val(false)]
    it_interprets %q(""  == {}),       [val(false)]
    it_interprets %q(""  == {a: 1}),   [val(false)]
  end

  describe "#!=" do
    it_interprets %q(""       != ""),       [val(false)]
    it_interprets %q("hello"  != "hello"),  [val(false)]
    it_interprets %q(""       != "hello"),  [val(true)]
    it_interprets %q("hello"  != ""),       [val(true)]
    it_interprets %q("\0"     != ""),       [val(true)]

    it_interprets %q("hello world"  != "helloworld"),  [val(true)]

    it_interprets %q("hello"  != nil),      [val(true)]
    it_interprets %q("hello"  != true),     [val(true)]
    it_interprets %q("hello"  != false),    [val(true)]
    it_interprets %q("hello"  != 0),        [val(true)]
    it_interprets %q("hello"  != 1),        [val(true)]
    it_interprets %q("hello"  != 0.0),      [val(true)]
    it_interprets %q("hello"  != 1.0),      [val(true)]
    it_interprets %q("hello"  != :hi),      [val(true)]
    it_interprets %q("hello"  != []),       [val(true)]
    it_interprets %q("hello"  != [1, 2]),   [val(true)]
    it_interprets %q("hello"  != {}),       [val(true)]
    it_interprets %q("hello"  != {a: 1}),   [val(true)]

    it_interprets %q(""  != nil),      [val(true)]
    it_interprets %q(""  != true),     [val(true)]
    it_interprets %q(""  != false),    [val(true)]
    it_interprets %q(""  != 0),        [val(true)]
    it_interprets %q(""  != 1),        [val(true)]
    it_interprets %q(""  != 0.0),      [val(true)]
    it_interprets %q(""  != 1.0),      [val(true)]
    it_interprets %q(""  != :hi),      [val(true)]
    it_interprets %q(""  != []),       [val(true)]
    it_interprets %q(""  != [1, 2]),   [val(true)]
    it_interprets %q(""  != {}),       [val(true)]
    it_interprets %q(""  != {a: 1}),   [val(true)]
  end
end
