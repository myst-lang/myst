require "stdlib/spec.mt"

describe("Not operator") do
  it("works on boolean") do
    assert(!true).is_false
    assert(!false).is_true
  end

  it("works on array") do
    assert(![]).is_false
  end

  it("works on string") do
    assert(!"Hello").is_false
  end

  it("calls `!` on custom types") do
    deftype Foo
      def !
        :called_not
      end
    end

    assert(!%Foo{}).equals(:called_not)
  end

  it("can be chained to booleanize a value") do
    assert(!!"hello").is_true
  end
end
