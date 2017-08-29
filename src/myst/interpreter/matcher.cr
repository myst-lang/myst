require "./calculator.cr"

module Myst
  class MatchError < Exception
    def initialize(pattern, value)
      @message = "Failed to match `#{pattern} =: #{value}`"
    end
  end


  class Matcher
    property interpreter : Interpreter

    def initialize(@interpreter : Interpreter); end


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
      # The separation of value Literals here is due to a nuance of how type
      # inference works in Crystal. If all of the value literals are put into a
      # single `when` clause, the inference attempts to find the lowest common
      # base class between them which it deems `Myst::Node+`. However,
      # `match_value` is obviously not defined for all Node types, so
      # compilation fails.
      #
      # This inference only seems to happen when more than 2 types are present
      # in a given clause, so they have been split out here.
      case pattern
      when AST::BooleanLiteral
        match_value(pattern, value)
      when AST::FloatLiteral, AST::IntegerLiteral
        match_value(pattern, value)
      when AST::StringLiteral, AST::SymbolLiteral
        match_value(pattern, value)
      when AST::VariableReference
        bind_variable(pattern, value)
      when AST::ValueInterpolation
        match_value_interpolation(pattern, value)
      when AST::ListLiteral
        match_list(pattern, value)
      when AST::MapLiteral
        match_map(pattern, value)
      else
        raise MatchError.new(pattern, value)
      end
    end


    def bind_variable(pattern : AST::VariableReference, value : Value)
      @interpreter.symbol_table[pattern.name] = value
      return value
    end

    def match_value(pattern : AST::IntegerLiteral | AST::FloatLiteral | AST::StringLiteral | AST::SymbolLiteral | AST::BooleanLiteral, value : Value)
      return_if_equal(Value.from_literal(pattern), value)
      raise MatchError.new(pattern, value)
    end

    def match_value_interpolation(pattern : AST::ValueInterpolation, value : Value)
      @interpreter.recurse(pattern)
      left = @interpreter.stack.pop()
      return_if_equal(left, value)
      raise MatchError.new(pattern, value)
    end

    def match_list(pattern : AST::ListLiteral, value : Value)
      if value.is_a?(TList)
        pattern.elements.children.each_with_index{ |el, idx| match(el, value.value[idx]) }
        return value
      else
        raise MatchError.new(pattern, value)
      end
    end

    def match_map(pattern : AST::MapLiteral, value : Value)
      if value.is_a?(TMap)
        pattern.elements.children.each do |e|
          entry = e.as(AST::MapEntryDefinition)
          @interpreter.recurse(entry.key)
          pattern_key = @interpreter.stack.pop

          if value.has_key?(pattern_key)
            match(entry.value, value.reference(pattern_key))
          else
            raise MatchError.new(pattern, value)
          end
        end
        return value
      else
        raise MatchError.new(pattern, value)
      end
    end
  end
end
