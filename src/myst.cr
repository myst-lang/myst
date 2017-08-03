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


# Parse the program into an AST
begin
  # Enforce that the main program file is not nil. This should never be an
  # issue, as this is the first file to be loaded, so `require` _should_ always
  # work (if the file cannot be loaded, an error will be raised instead).
  program = Myst::DependencyLoader.require(Myst::TString.new(source_file), nil).not_nil!
rescue e
  STDERR.puts(e.message)
  exit 1
end


if show_ast
  visitor = Myst::TreeDumpVisitor.new
  output = IO::Memory.new
  program.accept(visitor, output)
  puts output.to_s.strip
end

unless dry_run
  # Interpret the program
  interpreter = Myst::Interpreter.new
  program.accept(interpreter, STDOUT)
end
