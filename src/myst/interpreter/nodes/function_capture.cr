module Myst
  class Interpreter
    def visit(node : FunctionCapture)
      value =
        case value_node = node.value
        when Call
          _, func = lookup_call(value_node)
          func
        else
          visit(value_node)
          @stack.pop
        end

      # Only Function values can be captured. Any other value is an error.
      unless value.is_a?(TFunctor)
        raise RuntimeError.new(TString.new("Expected a function to capture"), callstack)
      end

      @stack.push(value)
    end
  end
end
