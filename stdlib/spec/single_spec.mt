defmodule Spec
  deftype SingleSpec
    def initialize(name : String)
      @name = name
      @container = nil
    end

    def name; @name; end

    def run(&block)
      block()
      STDOUT.print(Color.colored(".", :green))
    rescue failure
      STDOUT.puts("\n")
      STDOUT.puts(Color.colored("  <(describe_stack.pop.get_path(@name))>", :red))
      STDOUT.puts(Color.colored("    <(failure)>", :red))
      STDOUT.puts
      exit(1)
    end
  end
end
