# Just telling warn() we're not in test mode (test  declaration in
# spec/spec_helper.cr)
ENV["MYST_ENV"] = "prod"

class Cli
  def self.run
    source_file = ""
    show_ast = false
    dry_run = false
    eval = false

    OptionParser.parse! do |opts|
      opts.banner = "Usage: myst [filename] [options]"

      opts.on("-h", "--help", "Display this help message.") do
        puts opts
        exit
      end

      opts.on("-v", "Display the version of the Myst interpreter.") do
        puts Myst.version
        exit
      end

      opts.on("-vv", "Display more version information.") do
        puts Myst.verbose_version
        exit
      end

      opts.on("--ast", "Display the parsed AST for the input file. Code will not be executed if set.") do
        show_ast = true
        dry_run = true
      end

      opts.on("-e", "--eval", "Eval code from args") do
        eval = true
      end

      # Ignore invalid options
      opts.invalid_option { }

      opts.unknown_args do |before_dash|
        if before_dash.size > 0
          unless eval
            source_file = before_dash.shift
          else
						source_file = before_dash.select do |i|
							if(File.file? i) 
								STDERR.puts ("Do not specify files with the eval switch")
								exit 1
							end

							(!i.starts_with? "--")
						end.join "\n"
          end
        end
      end
    end

    if source_file.empty?
      STDERR.puts("No source file given.")
      exit 1
    end

    # Parse the program into an AST
    begin
      program = unless eval
									Parser.for_file(source_file).parse
								else
									Parser.for_content(source_file).parse
								end
    rescue e
      STDERR.puts(e.message)
      exit 1
    end

    if show_ast
      visitor = ASTViewer.new(STDOUT)
      program.accept(visitor)
    end

    interpreter = Interpreter.new
    # Load the prelude file
    prelude_require = Require.new(StringLiteral.new("stdlib/prelude.mt")).at(Location.new(__DIR__))
    interpreter.run(prelude_require)

    # Interpret the program
    interpreter.run(program)
  end
end
