module Myst
  class Interpreter
    def visit(node : ListLiteral)
      elements = node.elements.map do |elem|
        elem.accept(self)
        stack.pop
      end

      stack.push(TList.new(elements))
    end

    def visit(node : MapLiteral)
      entries = node.entries.reduce(Hash(Value, Value).new) do |map, entry|
        entry.key.accept(self)
        key = stack.pop
        entry.value.accept(self)
        value = stack.pop
        map[key] = value
        map
      end

      stack.push(TMap.new(entries))
    end

    def visit(node : Literal)
      stack.push(Value.from_literal(node))
    end
  end
end
