require "stdlib/spec.mt"

describe("Not operator") do
  it("works on boolean") do
    assert(!true == false)
    assert(!false == true)
  end

  it("works on array") do
    assert(![] == false)
  end

  it("works on string") do
    assert(!"Hello" == false)
  end

  it("calls `!` on custom types") do
    deftype Foo
      def !
        :called_not
      end
    end

    assert(!%Foo{} == :called_not)
  end

  it("can be chained to booleanize a value") do
    assert(!!"hello" == true)
  end
end
