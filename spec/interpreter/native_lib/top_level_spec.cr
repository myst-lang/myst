require "../../spec_helper.cr"
require "../../support/interpret.cr"
require "benchmark"

describe "NativeLib - Top level methods" do

  # Generally not to sure about the precision of the test
  # Results vary a lot
  describe "#sleep" do
    it "sleeps for as many milliseconds as provided" do
      vm = VM.for_content "sleep(0.01)", with_stdlib?: false
      Benchmark.realtime do
        vm.run
      end.total_milliseconds.should be_close 10, 15 # (expected, tolerance)
    end

    # This time its an Integer as argument
    # 0 so it won't make the specs take forever
    it "Or as many seconds as provided" do
      vm = VM.for_content "sleep(0)", with_stdlib?: false
      Benchmark.realtime do
        vm.run
      end.total_milliseconds.should be_close 0, 15
    end
  end
end
