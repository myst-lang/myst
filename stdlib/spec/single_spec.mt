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
      
      last = describe_stack.last?      
      
      when last
        STDOUT.puts(Color.colored("  <(last.get_path(@name, describe_stack.size -1))>", :red))
      else
        STDOUT.puts(Color.colored("  <(@name)>"), :red)
      end

      STDOUT.puts(Color.colored("    <(failure)>", :red))
      STDOUT.puts
      exit(1)
    end
  end
end
