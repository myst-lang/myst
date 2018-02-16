defmodule Spec
  deftype DescribeContainer
    def initialize(name : String)
      @name = name      
    end

    def name; @name; end

    def get_path(current : String)
      when !describe_stack.empty?
        return describe_stack.pop.get_path("<(@name)> <(current)>")
      else
        "<(@name)> <(current)>"
      end
    end
  end
end
