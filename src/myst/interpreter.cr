require "./visitor"
require "./interpreter"

module Myst
  class Interpreter < Visitor
    visit AST::Node do
      raise "Unsupported node `#{node.class.name}`"
    end
  end
end
