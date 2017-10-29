require "./io.mt"

defmodule Spec
  deftype AssertionFailure
    def initialize(name : String)
      @name = name
    end

    def name
      @name
    end

    def to_s
      @name
    end
  end

  def it(name, &block)
    block()
  rescue failure : AssertionFailure
    IO.puts("Spec `" + failure.to_s + "` failed")
  end

  def it(&block)
    it("unnamed") { }
  end

  def it(name)
    it(name) { }
  end


  def assert(assertion)
    unless assertion
      raise %AssertionFailure{"thing"}
    end
  end


  def describe(name, &block)
    block()
  end
end
