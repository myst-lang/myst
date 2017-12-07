require "stdlib/spec.mt"

describe("Map#size") do
  it("should return 0 when size is 0") do
    assert({}.size == 0)
  end

   it("should return 2 when size is 2") do
    assert({key: 1, b: "hello"}.size == 2)
  end
end

