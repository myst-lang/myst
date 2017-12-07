require "stdlib/spec.mt"

describe("List#size") do
  it("should return 0 when size is 0") do
    assert([].size == 0)
  end

  it("should return 3 when size is 3") do
    assert([1,2,3].size == 3)
  end
end
