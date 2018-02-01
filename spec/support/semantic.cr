require "./nodes.cr"

def analyze(node : Node, visitor = SemanticVisitor.new, mock_output = true, capture_failures = false)
  if mock_output
    visitor.output = IO::Memory.new
    visitor.errput = IO::Memory.new
  end

  visitor.capture_failures = capture_failures

  visitor.visit(node)
  visitor
end

def analyze(node : String, visitor = SemanticVisitor.new, mock_output = true, capture_failures = false)
  program = parse_program(node)
  analyze(program, visitor, mock_output: mock_output, capture_failures: capture_failures)
end
