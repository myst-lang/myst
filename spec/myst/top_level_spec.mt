describe("NativeLib - Top level methods") do
  # Generally not to sure about the precision of the test
  # Results vary a lot
  describe("#sleep") do
    it("sleeps for as many milliseconds as provided") do
      start = Time.now
      sleep(0.01)
      passed = (Time.now.millisecond - start.millisecond)

      # Assert 10 milliseconds has passed, with a 5 millisecond tolerance
      assert(passed > 5 && passed < 15)
    end

    # This time its an Integer as argument
    # 0 so it won't make the specs take forever
    it("Or as many seconds as provided") do
      start = Time.now
      sleep(0)
      passed = (Time.now.millisecond - start.millisecond)

      # Assert 0 milliseconds has passed, with a 5 millisecond tolerance
      assert(passed > -5 && passed < 5)
    end     
  end
end
