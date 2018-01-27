require "option_parser"

module Myst
  class Cli
    def self.run
      source = ""
      show_ast = false
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
        end

        opts.on("-e", "--eval", "Eval code from args") do
          eval = true
        end

        # Ignore invalid options
        opts.invalid_option { }

        opts.unknown_args do |before_dash|
          if before_dash.size > 0
            unless eval
              source = before_dash.shift
            else
              source = before_dash.join("\n")
            end
          end
        end
      end

      if source.empty?
        STDERR.puts("No#{eval ? "thing to evaluate" : " source file"} given.")
        exit 1
      end

      vm = eval ? VM.for_content(source, use_stdios?: true) : VM.for_file(source, use_stdios?: true)

      if show_ast
        vm.print_ast
        exit
      else
        vm.run
      end
    end
  end
end