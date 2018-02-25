module Myst
  class Interpreter
    def visit(node : ListLiteral)
      elements = [] of MTValue

      node.elements.each do |elem|
        elem.accept(self)
        # A Splat in a List literal should have its result concatenated in
        # place into the new List object. In other words, a Splat should be
        # transparent to listing out the values directly in the literal.
        if elem.is_a?(Splat)
          # The result of a Splat _must_ be a list, so this assertion should
          # never fail.
          splat_result = stack.pop.as(TList)
          elements.concat(splat_result.elements)
        else
          elements << stack.pop
        end
      end

      stack.push(TList.new(elements))
    end

    def visit(node : MapLiteral)
      entries = node.entries.reduce(Hash(MTValue, MTValue).new) do |map, entry|
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
          Interpreter.__value_from_literal(piece)
        else
          visit(piece)
          expr_result = stack.pop
          value_to_s = __scopeof(expr_result)["to_s"].as(TFunctor)
          result = Invocation.new(
            self,
            value_to_s,
            expr_result,
            [] of MTValue,
            nil
          ).invoke.as(String)
        end
      end

      full_str = strs.join
      stack.push(full_str)
    end

    def visit(node : Literal)
      stack.push(Interpreter.__value_from_literal(node))
    end
  end
end
