require "./calculator.cr"

module Myst
  class MatchError < Exception
    def initialize(pattern, value, msg=nil)
      @message = <<-MESSAGE
        Failed to match `#{pattern} =: #{value}`.
        Reason: #{msg}
      MESSAGE
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
      when AST::ListLiteral
        match_list(pattern, value)
      when AST::MapLiteral
        match_map(pattern, value)
      when AST::Var
        bind_variable(pattern.name, value)
      when AST::Const
        match_type_restriction(pattern, value)
      when AST::ValueInterpolation
        match_value_interpolation(pattern, value)
      else
        raise MatchError.new(pattern, value)
      end
    end


    def bind_variable(name : String, value : Value)
      @interpreter.symbol_table[name] = value
      return value
    end

    def match_type_restriction(pattern : AST::Const, value : Value)
      if value.type_name == pattern.name
        value
      else
        raise MatchError.new(pattern, value, "Type restriction not satisfied.")
      end
    end

    def match_value(pattern : AST::IntegerLiteral | AST::FloatLiteral | AST::StringLiteral | AST::SymbolLiteral | AST::BooleanLiteral, value : Value)
      return_if_equal(Value.from_literal(pattern), value)
      raise MatchError.new(pattern, value)
    end

    def match_value_interpolation(pattern : AST::ValueInterpolation, value : Value)
      @interpreter.recurse(pattern)
      left = @interpreter.stack.pop
      return_if_equal(left, value)
      raise MatchError.new(pattern, value)
    end

    def match_map(pattern : AST::MapLiteral, value : Value)
      if value.is_a?(TMap)
        pattern.elements.each do |entry|
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

    def match_list(pattern : AST::ListLiteral, value : Value)
      if value.is_a?(TList)
        left, splat, right = chunk_list_pattern(pattern)

        value_elements = value.value.dup
        left.each { |element_pattern| match(element_pattern, value_elements.shift)  }
        right.each{ |element_pattern| match(element_pattern, value_elements.pop)    }
        if splat.is_a?(AST::Splat) && (val = splat.value).is_a?(AST::Var)
          bind_variable(val.name, TList.new(value_elements))
        else
          unless value_elements.empty?
            raise MatchError.new(pattern, value, "Not all elements matched")
          end
        end

        return value
      else
        raise MatchError.new(pattern, value)
      end
    end


    # Return a 3-tuple representing the segments of a List pattern in the
    # format `{pre-splat, splat-collector, post-splat}`. The splat collector
    # will be the single splat collector in the List literal. If more than
    # one splat exists in the literal, an error will be raised.
    private def chunk_list_pattern(pattern : AST::ListLiteral)
      left  = [] of AST::Node
      splat = nil
      right = [] of AST::Node

      past_splat = false
      pattern.elements.each do |el|
        if el.is_a?(AST::Splat)
          if past_splat
            raise "More than one splat collector in a List pattern is not allowed."
          else
            splat = el
            past_splat = true
          end
        elsif past_splat
          right.unshift(el)
        else
          left.push(el)
        end
      end

      {left, splat, right}
    end
  end
end
