require "../spec_helper.cr"
require "./nodes.cr"

def it_interprets(node : String, expected_stack : Array(Myst::Value), itr=Interpreter.new, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  it %Q(interprets #{node}), file, line, end_line do
    program = parse_program(node)
    itr.run(program)

    unless expected_stack.empty?
      stack = expected_stack
      if itr.stack.size != stack.size
        raise <<-ERROR_MSG
          Stack size does not match expected (#{itr.stack.size} vs. #{stack.size}):
              expected: #{stack.inspect}

              got: #{itr.stack.inspect}
        ERROR_MSG
      end

      itr.stack.zip(expected_stack).each do |stack, expected|
        stack.should eq(expected)
      end
    end
  end
end

def it_interprets(node : String, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  itr = Interpreter.new
  expected_stack = yield itr
  it_interprets(node, expected_stack, itr, file, line, end_line)
end

def it_interprets(node : String, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  it_interprets(node, [] of Myst::Value, Interpreter.new, file, line, end_line)
end


def it_interprets_with_assignments(node : String, assignments : Hash(String, Myst::Value), itr=Interpreter.new, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  it %Q(interprets #{node}), file, line, end_line do
    program = parse_program(node)
    itr.run(program)

    assignments.each do |name, value|
      itr.current_scope[name.to_s].should eq(value)
    end
  end
end

def interpret_with_mocked_output(source)
  itr = Interpreter.new(output: IO::Memory.new, input: IO::Memory.new, errput: IO::Memory.new)
  parse_and_interpret(source, itr)
end

def interpret_with_mocked_input(source, input)
  if input
    io = IO::Memory.new(input)
  else
    io = IO::Memory.new
  end

  itr = Interpreter.new(output: IO::Memory.new, input: io, errput: IO::Memory.new)
  parse_and_interpret(source, itr)
end

def it_raises(source, error, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  it "raises `#{error}` from `#{source}`", file, line, end_line do
    itr = interpret_with_mocked_output(source)
    itr.errput.to_s.should contain(error)
  end
end

# Parse and run the given program and test if the number of warnings is
# equal to expected
def it_warns(source, expected, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  it "raises warning from `#{source}`", file, line, end_line do
    interpreter=Interpreter.new
    program = parse_program(source)
    interpreter.run(program)
    interpreter.warnings.should eq expected
  end
end

def it_does_not_interpret(node : String, message=nil, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  it %Q(does not interpret #{node}), file, line, end_line do
    itr = Interpreter.new
    program = parse_program(node)
    exception = expect_raises(RuntimeError) do
      itr.run(program, capture_errors: false)
    end

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
  TList.new(node.map{ |n| val(n) }).as(Myst::Value)
end

def val(node : Hash(K, V)) forall K, V
  node.reduce(TMap.new) do |map, (k, v)|
    map.entries[val(k)] = val(v)
    map
  end.as(Myst::Value)
end

def val(node); val(l(node)); end
