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

    def visit(node : InterpolatedStringLiteral)
      strs = node.components.map do |piece|
        case piece
        when StringLiteral
          Value.from_literal(piece).as(TString)
        else
          visit(piece)
          expr_result = stack.pop
          value_to_s = __scopeof(expr_result)["to_s"].as(TFunctor)
          result = Invocation.new(
            self,
            value_to_s,
            expr_result,
            [] of Value,
            nil
          ).invoke.as(TString)
        end
      end

      full_str = strs.map(&.value).join
      stack.push(TString.new(full_str))
    end

    def visit(node : Literal)
      stack.push(Value.from_literal(node))
    end
  end
end
