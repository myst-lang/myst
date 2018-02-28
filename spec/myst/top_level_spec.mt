describe("NativeLib - Top level methods") do
  # Generally not to sure about the precision of the test
  # Results vary a lot
  describe("#sleep") do
    it("sleeps for as many milliseconds as provided") do
      start = Time.now
      sleep(0.01)
      passed = (Time.now.millisecond - start.millisecond)

      # Assert 10 milliseconds has passed, with a 5 millisecond tolerance
      assert(passed).between(5, 15)
    end

    # This time its an Integer as argument
    # 0 so it won't make the specs take forever
    it("or as many seconds as provided") do
      start = Time.now
      sleep(0)
      passed = (Time.now.millisecond - start.millisecond)

      # Assert 0 milliseconds has passed, with a 5 millisecond tolerance
      assert(passed).between(-5, 5)
    end
  end

  describe("#doc") do
    it("returns the doc comment for a function definition") do
      # This method has documentation.
      def foo; end

      assert(doc((&foo)) == "This method has documentation.\n")
    end

    it("returns the doc comment for a module definition") do
      # Docs for Foo module.
      defmodule Foo; end

      assert(doc(Foo) == "Docs for Foo module.\n")
    end

    it("returns the doc comment for a type definition") do
      # Docs for Foo type.
      deftype Foo; end

      assert(doc(Foo) == "Docs for Foo type.\n")
    end

    it("returns the doc comment for a method within a module") do
      # Not these Docs
      defmodule Foo
        # These are the docs.
        def foo; end
      end

      assert(doc((&Foo.foo)) == "These are the docs.\n")
    end
  end
end
