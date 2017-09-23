require "../spec_helper.cr"

macro it_interprets(node, expected_stack)
  it %q(interprets {{node.id}}) do
    interpreter = Interpreter.new
    {{node}}.accept(interpreter)

    {% unless expected_stack.empty? %}
      %stack = {{expected_stack}}
      if interpreter.stack.size != %stack.size
        raise "Stack size does not match expected (#{interpreter.stack.size} vs. #{%stack.size})"
      end

      interpreter.stack.zip({{expected_stack}}).each do |stack, expected|
        stack.should eq(expected)
      end
    {% end %}
  end
end
