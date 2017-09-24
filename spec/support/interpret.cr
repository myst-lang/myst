require "../spec_helper.cr"

macro it_interprets(node, expected_stack)
  it %q(interprets {{node.id}}) do
    {% if node.is_a?(StringLiteral) %}
      %program = parse_program({{node}})
    {% else %}
      %program = {{node}}
    {% end %}
    interpreter = Interpreter.new
    %program.accept(interpreter)

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

# val(node)
#
# Run `Value.from_literal` on the given node and return the result. If `node`
# is not already a Node, it will be run through `l` first.
def val(node : Node)
  Myst::Value.from_literal(node)
end

def val(node); val(l(node)); end
