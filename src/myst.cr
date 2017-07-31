require "option_parser"

require "./myst/parser"
require "./myst/visitors/tree_dump_visitor"
require "./myst/interpreter"

source_file = ""
show_ast = false
dry_run = false

OptionParser.parse! do |opts|
  opts.banner = "Usage: myst [filename] [options]"

  opts.on("-h", "--help", "Display this help message.") do
    puts opts
    exit
  end

  opts.on("--ast", "Display the parsed AST for the input file. Code will not be executed if set.") do
    show_ast = true
    dry_run = true
  end

  # Ignore invalid options
  opts.invalid_option{ }

  opts.unknown_args do |before_dash|
    if before_dash.size > 0
      source_file = before_dash.shift
    end
  end
end


if source_file.empty?
  STDERR.puts("No source file given.")
  exit 1
end

unless File.exists?(source_file) && File.readable?(source_file)
  STDERR.puts("File '#{source_file}' is not available (unreadable or does not exist).")
  exit 1
end


# Parse the lexemes into an AST
parser = Myst::Parser.new(IO::Memory.new(File.read(source_file)))
program = parser.parse_block

# Print the AST to the console for debugging
visitor = Myst::TreeDumpVisitor.new
output = IO::Memory.new
program.accept(visitor, output)

if show_ast
  puts output.to_s.strip
end

unless dry_run
  # Interpret the program
  interpreter = Myst::Interpreter.new
  program.accept(interpreter, STDOUT)
end
