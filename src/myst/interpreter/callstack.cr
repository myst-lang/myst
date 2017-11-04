module Myst
  struct Callstack
    property context : Array(Node)

    def initialize(@context = [] of Node)
    end

    delegate reverse_each, push, pop, to: context
  end
end
