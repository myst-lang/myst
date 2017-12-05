require "stdlib/spec.mt"

describe("String#empty?") do
  it("with an empty string") do
    assert("".empty?)
  end

  it("with a non-empty string") do
    assert("test".empty? == false)
  end
end
