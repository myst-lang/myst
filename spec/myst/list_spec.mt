require "stdlib/spec.mt"

describe("List#size") do
  it("should return 0 when size is 0") do
    assert([].size == 0)
  end

  it("should return 3 when size is 3") do
    assert([1,2,3].size == 3)
  end
end

describe("List#empty?") do
  it("should return true when list size is 0") do
    assert([].empty? == true)
  end

  it("should return false when list size is 2") do
    assert([1, 2].empty? == false)
  end
end
