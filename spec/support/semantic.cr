require "./nodes.cr"

def analyze(node : String, visitor=SemanticVisitor.new, mock_output=true, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  if mock_output
    visitor.output = IO::Memory.new
    visitor.errput = IO::Memory.new
  end

  program = parse_program(node)
  visitor.visit(program)
  visitor
end
