require "../spec_helper.cr"

def it_interprets(node : String, expected_stack, itr=Interpreter.new)
  it %Q(interprets #{node}) do
    program = parse_program(node)
    program.accept(itr)

    unless expected_stack.empty?
      stack = expected_stack
      if itr.stack.size != stack.size
        raise "Stack size does not match expected (#{itr.stack.size} vs. #{stack.size})"
      end

      itr.stack.zip(expected_stack).each do |stack, expected|
        stack.should eq(expected)
      end
    end
  end
end

def it_interprets(node : String)
  itr = Interpreter.new
  expected_stack = yield itr
  it_interprets(node, expected_stack, itr)
end

def it_does_not_interpret(node : String, message=nil)
  it %Q(does not interpret #{node}) do
    itr = Interpreter.new
    program = parse_program(node)
    exception = expect_raises{ program.accept(itr) }

    if message
      (exception.message || "").downcase.should match(message)
    end
  end
end

# val(node)
#
# Run `Value.from_literal` on the given node and return the result. If `node`
# is not already a Node, it will be run through `l` first.
def val(node : Node)
  Myst::Value.from_literal(node).as(Myst::Value)
end

def val(node : Array(T)) forall T
  list = TList.new(node.map{ |n| val(n) })
end

def val(node : Hash(K, V)) forall K, V
  node.reduce(TMap.new) do |map, (k, v)|
    map.entries[val(k)] = val(v)
    map
  end
end

def val(node); val(l(node)); end
