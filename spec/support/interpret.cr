require "../spec_helper.cr"

macro it_interprets(node, expected_stack)
  it %q(interprets {{node.id}}) do
    {% if node.is_a?(StringLiteral) %}
      %program = parse_program({{node}})
    {% else %}
      %program = {{node}}
    {% end %}
    itr = Interpreter.new
    %program.accept(itr)

    {% unless expected_stack.empty? %}
      %stack = {{expected_stack}}
      if itr.stack.size != %stack.size
        raise "Stack size does not match expected (#{itr.stack.size} vs. #{%stack.size})"
      end

      itr.stack.zip({{expected_stack}}).each do |stack, expected|
        stack.should eq(expected)
      end
    {% end %}
  end
end

macro it_does_not_interpret(node, message=nil)
  it %q(does not interpret {{node.id}}) do
    {% if node.is_a?(StringLiteral) %}
      %program = parse_program({{node}})
    {% else %}
      %program = {{node}}
    {% end %}
    itr = Interpreter.new

    exception = expect_raises{ %program.accept(itr) }

    {% if message %}
      (exception.message || "").downcase.should match({{message}})
    {% end %}
  end
end

# val(node)
#
# Run `Value.from_literal` on the given node and return the result. If `node`
# is not already a Node, it will be run through `l` first.
def val(node : Node)
  Myst::Value.from_literal(node).as(Myst::Value)
end

def val(node); val(l(node)); end
