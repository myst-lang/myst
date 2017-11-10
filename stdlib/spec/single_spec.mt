defmodule Spec
  deftype SingleSpec
    def initialize(name : String)
      @name = name
    end

    def name; @name; end

    def run(&block)
      block()
      IO.puts(".")
    rescue failure : AssertionFailure
      IO.puts(failure)
      exit(127)
    end


    def assert(assertion)
      unless assertion
        raise %AssertionFailure{@name, true, assertion}
      end
    end
  end
end
