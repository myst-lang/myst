module Myst
  class MatchError < Exception
    def initialize(pattern, value)
      @message = "Failed to match `#{pattern} =: #{value}`"
    end
  end

  # This module is responsible for handling pattern-matching assignment. The
  # `match` method takes a pattern (`left`) and a Value (`right`) and attempts
  # to deconstruct the Value according to the pattern.
  #
  # The pattern can be any plain value node (including interpolated values) for
  # simple matching, a variable reference for simple assignment, or a List/Map
  # literal for decomposition. In the latter case, each entry in the collection
  # will be recursively matched with the corresponding entry in the Value.
  #
  # If the match succeeds, the return value will be the Value of `right`.
  # If the match fails, it will raise a `MatchError` with relevant information.
  module Matcher
    # Return the right-side value if the left and right values are equal.
    # The comparison is done as `right == left`.
    macro return_if_equal(left, right)
      return {{right}} if Calculator.do(Token::Type::EQUALEQUAL, {{right}}, {{left}}).truthy?
    end

    # Perform pattern matching for the given pattern and value.
    # If the match is successful, this function returns the value.
    # If the match fails, a `MatchError` is raised.
    def match(pattern : AST::Node, value : Value)
      case pattern
      when AST::IntegerLiteral, AST::FloatLiteral, AST::StringLiteral, AST::SymbolLiteral, AST::BooleanLiteral
        return_if_equal(Value.from_literal(pattern), value)
      when AST::VariableReference
        bind(pattern, value)
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


    private def bind(node : AST::VariableReference, right : Value)
      @symbol_table[node.name] = right
    end
  end
end
