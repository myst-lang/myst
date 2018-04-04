require "stdlib/spec.mt"


describe("File") do
  describe(".open") do
    it("returns a new File instance for the given file") do
      file = File.open("spec/support/misc/fixed_size_file.txt", "r")
      assert(file.type.to_s).equals("File")
    end

    it("defaults to 'read' mode if no mode is given") do
      file = File.open("spec/support/misc/fixed_size_file.txt")
      assert(file.mode).equals("r")
    end
  end


  describe("#close") do
    # TODO: test that the file descriptor is properly closed.
  end

  describe("#size") do
    it("returns an Integer of the number of bytes the file contains") do
      # `fixed_size_file.txt` should always be 63 bytes in size.
      file = %File{"spec/support/misc/fixed_size_file.txt", "r"}

      assert(file.size).equals(63)
    end
  end

  describe("#mode") do
    it("returns the mode string that the file was opened with") do
      file = %File{"spec/support/misc/fixed_size_file.txt", "r"}

      assert(file.mode).equals("r")
    end
  end

  describe("#path") do
    it("returns the path string given when opening the file") do
      file = %File{"spec/support/misc/fixed_size_file.txt", "r"}

      assert(file.path).equals("spec/support/misc/fixed_size_file.txt")
    end
  end
end
