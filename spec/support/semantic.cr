require "./nodes.cr"

def analyze(node : Node, visitor = SemanticVisitor.new, mock_output = true)
  if mock_output
    visitor.output = IO::Memory.new
    visitor.errput = IO::Memory.new
  end

  visitor.visit(node)
  visitor
end

def analyze(node : String, visitor = SemanticVisitor.new, mock_output = true)
  program = parse_program(node)
  analyze(program, visitor, mock_output: mock_output)
end
