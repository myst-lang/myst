require "stdlib/spec.mt"

describe("Type#to_s") do
  it("with a literal") do
    assert({}.type.to_s).equals("Map")
  end

  it("with user defined type") do
    deftype T
    end

    assert(T.to_s).equals("T")
  end
end
