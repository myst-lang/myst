defmodule Spec
  deftype SingleSpec
    def initialize(name : String)
      @name = name
      @container = nil
    end

    def name; @name; end

    def run(&block)
      block()
      STDOUT.print(".")
    rescue failure
      STDOUT.puts(failure)
      exit(1)
    end
  end
end
