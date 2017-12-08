require "stdlib/spec.mt"

describe("Type#to_s") do
  it("with a literal") do
    assert({}.type.to_s == "Map")
  end

  it("with user defined type") do
    deftype T
    end
    
    assert(T.to_s == "T")
  end
end
