require "../calculator.cr"

class Myst::Interpreter
  class MatchError < Exception
    def initialize(pattern, value)
      @message = "Failed to match `#{pattern} =: #{value}`"
    end
  end


  def visit(node : AST::PatternMatchingAssignment)
    recurse(node.value)
    result = match(node.pattern, stack.pop())
    stack.push(result)
  end


  # Return the right-side value if the left and right values are equal.
  # The comparison is done as `right == left`.
  macro return_if_equal(left, right)
    return {{right}} if Calculator.do(Token::Type::EQUALEQUAL, {{right}}, {{left}}).truthy?
  end


  # The `match` method takes a pattern (`left`) and a Value (`right`) and
  # attempts to deconstruct the Value according to the pattern.
  #
  # The pattern can be any plain value node (including interpolated values) for
  # simple matching, a variable reference for simple assignment, or a List/Map
  # literal for decomposition. In the latter case, each entry in the collection
  # will be recursively matched with the corresponding entry in the Value.
  #
  # If the match succeeds, the return value will be the Value of `right`.
  # If the match fails, it will raise a `MatchError` with relevant information.
  def match(pattern : AST::Node, value : Value)
    case pattern
    when AST::IntegerLiteral, AST::FloatLiteral, AST::StringLiteral, AST::SymbolLiteral, AST::BooleanLiteral
      return_if_equal(Value.from_literal(pattern), value)
    when AST::VariableReference
      @symbol_table[pattern.name] = value
      return value
    when AST::ValueInterpolation
      recurse(pattern)
      left = stack.pop()
      return_if_equal(left, value)
    when AST::ListLiteral
      if value.is_a?(TList)
        pattern.elements.children.each_with_index{ |el, idx| match(el, value.value[idx]) }
        return value
      end
    end

    raise MatchError.new(pattern, value)
  end
end
