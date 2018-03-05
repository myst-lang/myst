require "stdlib/spec.mt"


describe("File#open") do
  it("returns a new File instance for the given file") do
    file = File.open("spec/support/misc/fixed_size_file.txt", "r")

    assert(file.type.to_s).equals("File")
  end

  it("defaults to 'read' mode if no mode is given") do
    file = File.open("spec/support/misc/fixed_size_file.txt")
    assert(file.mode).equals("r")
  end
end

describe("File#close") do
  # TODO: test that the file descriptor is properly closed.
end

describe("File#size") do
  it("returns an Integer of the number of bytes the file contains") do
    # `fixed_size_file.txt` should always be 63 bytes in size.
    file = %File{"spec/support/misc/fixed_size_file.txt", "r"}

    assert(file.size).equals(63)
  end
end
