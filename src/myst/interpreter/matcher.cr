module Myst
  class Interpreter
    class MatchError < Exception
      def initialize
        @message = "match failure"
      end
    end

    def match(pattern : Node, value : Value)
      case pattern
      when ListLiteral
        match_list(pattern, value)
      when MapLiteral
        match_map(pattern, value)
      when Literal
        # All other literal types are simple value matches
        match_value(pattern, value)
      when ValueInterpolation
        match_value(pattern, value)
      when Var, Underscore
        # Vars are always assigned in the current scope.
        current_scope.assign(pattern.name, value)
      when IVar
        # Vars are always assigned in the current scope.
        current_self.ivars.assign(pattern.name, value)
      when Const
        # Constants can't be re-assigned, so they are matched as if they were
        # literal values
        match_value(pattern, value)
      else
        raise MatchError.new
      end
    end

    # For simplicity and efficiency, the equality of values according to a
    # match operation is determined by the native equality of the values, not
    # by any override of `==`.
    private def match_value(pattern : Node, right : Value)
      visit(pattern)
      left = stack.pop
      success =
        if left.is_a?(TType) && !right.is_a?(TType)
          # For types, check that `right` is either an instance of that type, or
          # the type itself.
          left == __typeof(right)
        else
          left == right
        end

      success || raise MatchError.new
    end

    private def match_list(pattern : ListLiteral, value : Value)
      raise MatchError.new unless value.is_a?(TList)

      left, splat, right = chunk_list_pattern(pattern)

      value_elements = value.elements.dup
      left.each { |element_pattern| match(element_pattern, value_elements.shift)  }
      right.each{ |element_pattern| match(element_pattern, value_elements.pop)    }
      if splat.is_a?(Splat)
        match(splat.value, TList.new(value_elements))
      else
        unless value_elements.empty?
          raise MatchError.new
        end
      end
    end

    private def match_map(pattern : MapLiteral, value : Value)
      raise MatchError.new unless value.is_a?(TMap)

      pattern.entries.each do |entry|
        visit(entry.key)
        pattern_key = stack.pop

        if right_value = value.entries[pattern_key]?
          match(entry.value, right_value)
        else
          raise MatchError.new
        end
      end
    end


    # Return a 3-tuple representing the segments of a List pattern in the
    # format `{pre-splat, splat-collector, post-splat}`. The splat collector
    # will be the single splat collector in the List literal. If more than
    # one splat exists in the literal, an error will be raised.
    private def chunk_list_pattern(pattern : ListLiteral)
      left  = [] of Node
      splat = nil
      right = [] of Node

      past_splat = false
      pattern.elements.each do |el|
        if el.is_a?(Splat)
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
