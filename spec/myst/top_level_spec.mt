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
    #doc foo
    #| Documentation for method foo.
    def foo; end

    #doc Foo
    #| Documentation for module Foo.
    defmodule Foo
      #doc foo
      #| method foo within Foo.
      def foo; end
    end

    #doc Bar
    #| Documentation for type Bar.
    deftype Bar
      #doc .baz
      #| static method baz within Bar.
      defstatic baz
      end

      #doc #baz
      #| instance method baz within Bar.
      def baz
      end
    end

    it("returns the doc comment for a function definition") do
      assert(doc("foo")).equals("Documentation for method foo.")
    end

    it("returns the doc comment for a module definition") do
      assert(doc("Foo")).equals("Documentation for module Foo.")
    end

    it("returns the doc comment for a type definition") do
      assert(doc("Bar")).equals("Documentation for type Bar.")
    end

    it("returns the doc comment for a method within a module") do
      assert(doc("Foo.foo")).equals("method foo within Foo.")
    end

    it("returns the doc comment for a static method within a type") do
      assert(doc("Bar.baz")).equals("static method baz within Bar.")
    end

    it("returns the doc comment for an instance method within a type") do
      assert(doc("Bar#baz")).equals("instance method baz within Bar.")
    end
  end
end
