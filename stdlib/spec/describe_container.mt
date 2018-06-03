defmodule Spec
  deftype DescribeContainer
    def initialize(name : String)
      @name = name
    end

    def name : String; @name; end

    def get_path(current : String, stack_index) : String
      when !describe_stack.empty? && next_describe = describe_stack[stack_index]
        return describe_stack[stack_index].get_path("<(current)>", stack_index - 1)
      else
        "<(@name)> <(current)>"
      end
    end
  end
end
