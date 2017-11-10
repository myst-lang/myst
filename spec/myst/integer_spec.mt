require "stdlib/spec.mt"

describe("Integer") do
  it("does addition") do
    assert(1 + 1 == 2)
    assert(2 + 2 == 4)
    assert(2_000 + 4_567 == 6_566)
  end
end
