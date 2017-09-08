require "option_parser"

require "./myst/**"
include Myst

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
  program = DependencyLoader.require(TString.new(source_file), nil).not_nil!
rescue e
  STDERR.puts(e.message)
  exit 1
end


# if show_ast
#   visitor = TreeDumpVisitor.new(STDOUT)
#   program.accept(visitor)
# end

unless dry_run
  # Interpret the program
  interpreter = Interpreter.new
  prelude = DependencyLoader.require(TString.new("stdlib/prelude.mt"), nil).not_nil!
  prelude.accept(interpreter)
  program.accept(interpreter)
end
