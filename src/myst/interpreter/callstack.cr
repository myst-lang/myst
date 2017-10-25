module Myst
  struct Callstack
    property context : Array(Node)

    def initialize(@context = [] of Node)
    end

    delegate each, push, pop, to: context
  end
end
