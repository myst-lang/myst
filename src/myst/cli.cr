require "option_parser"

module Myst
  class CLI
    def self.run
      source = ""
      show_ast = false
      eval = false
      stop_evaluation = false
      generate_docs = false
      docs_directory = Dir.current
      docs_yml = "./.mystdoc.yml"

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
          stop_evaluation = true
        end

        opts.on("--docs DIRECTORY", "Generate a JSON file containing documentation for the input file.") do |directory|
          generate_docs = true
          docs_directory = directory
        end

        opts.on("--doc-yml DOC_YML", "Use the given file in place of ./.mystdoc.yml when generating metadata for documentation.") do |yml_file|
          docs_yml = yml_file
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


      if generate_docs
        Doc::Generator.auto_document(docs_directory, docs_yml)
        exit
      end

      if source.empty?
        STDERR.puts("No#{eval ? "thing to evaluate" : " source file"} given.")
        exit 1
      end

      vm = eval ? VM.for_content(source, use_stdios?: true) : VM.for_file(source, use_stdios?: true)

      if show_ast
        vm.print_ast
        exit
      end

      unless stop_evaluation
        vm.run
      end
    end
  end
end
