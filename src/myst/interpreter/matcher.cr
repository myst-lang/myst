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
    private def match_value(pattern : Node, value : Value)
      visit(pattern)
      result = stack.pop

      raise MatchError.new unless result == value
    end

    private def match_list(pattern : ListLiteral, value : Value)
      raise MatchError.new unless value.is_a?(TList)

      if pattern.elements.size != value.elements.size
        raise MatchError.new
      end

      pattern.elements.zip(value.elements).each do |p, v|
        match(p, v)
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
  end
end
