require "./myst/parser"
require "./myst/visitors/tree_dump_visitor"
require "./myst/interpreter"

source_file = ARGV[0]?

unless source_file
  STDERR.puts("No source file given")
  exit 1
end

# Parse the lexemes into an AST
parser = Myst::Parser.new(IO::Memory.new(File.read(source_file)))
program = parser.parse_block

# Print the AST to the console for debugging
visitor = Myst::TreeDumpVisitor.new
output = IO::Memory.new
program.accept(visitor, output)
puts "\nAST DEBUG:"
puts output.to_s.strip

# Interpret the program
interpreter = Myst::Interpreter.new
program.accept(interpreter, STDOUT)
