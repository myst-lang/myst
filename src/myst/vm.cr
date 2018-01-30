module Myst
  class VM 
    getter interpreter        

    # This constructor is not really meant to be called unless you're initializing an "empty" vm
    # Instead `for_file` and `for_content` should be used
    # Many of these parameters would be rarely used
    # All having default values, i don't really think the amount of parameters is a problem
    def initialize(source : IO = IO::Memory.new, *, source_name : String = "eval_input", with_stdlib? : Bool = true,
                   use_stdios? : Bool = false, product? : Bool = true)            

      # Just telling warn() we're not in test mode (test  declaration in
      # spec/spec_helper.cr)
      ENV["MYST_ENV"] = product? ? "prod" : "test"


      @source = source
      @interpreter = Interpreter.new

      # See `#use_stdios=`
      self.use_stdios = use_stdios?

      @with_stdlib = with_stdlib?
      if @with_stdlib
        # Load the prelude file
        prelude_require = Require.new(StringLiteral.new("stdlib/prelude.mt")).at(Location.new(__DIR__))
        @interpreter.run(prelude_require)      
      end
      
      @program = uninitialized Expressions # The main program

      # Parse the program into an AST
      # This can throw an error (ParseError)
      @program = Parser.new(@source, source_name).parse

    end  

    def self.for_file(source_file : String, *, with_stdlib? : Bool = true, use_stdios? : Bool = false, product? : Bool = true)
      new(File.open(source_file), source_name: source_file, with_stdlib?: with_stdlib?, use_stdios?: use_stdios?, product?: product?)
    end

    def self.run(source_file : String, *, with_stdlib? : Bool = true, use_stdios? : Bool = false, product? : Bool = true)
      vm = self.for_file(source_file, with_stdlib?: with_stdlib?, use_stdios?: use_stdios?, product?: product?)
      vm.run
      vm
    end

    def self.for_content(string_source : String, *, with_stdlib? : Bool = true, use_stdios? : Bool = false, product? : Bool = true)
      new(IO::Memory.new(string_source), source_name: "eval_input", with_stdlib?: with_stdlib?, use_stdios?: use_stdios?, product?: product?)
    end

    def self.eval(string_source : String, *, with_stdlib? : Bool = true, use_stdios? : Bool = false, product? : Bool = true)
      vm = self.for_content(string_source, with_stdlib?: with_stdlib?, use_stdios?: use_stdios?, product?: product?)
      vm.run
      vm
    end    

    def print_ast(io : IO = STDOUT)
      visitor = ASTViewer.new(io)
      @program.not_nil!.accept(visitor)
    end

    # Runs the `@source` io
    def run
      # Interpret the program
      @interpreter.run @program.not_nil!
    end

    # Tries to run the provided string as a myst program
    def eval(program : String)
      @interpreter.run(Parser.for_content(program).parse)
    end

    # Runs file(s) and IO(s) 
    def run(*programs)
      programs.each do |program|
        @interpreter.run(case  program
                         when .is_a? String
                           Parser.for_file(program)
                         when .is_a? File
                           Parser.new(program, program.path)
                         when .is_a? IO 
                           Parser.new(program, "eval_input") 
                         else
                           STDERR.puts "Failed running #{program}, `#run` takes either a File, IO or a filepath as argument" 
                           exit 1
                         end.parse)
      end
    end

    def require(*programs) # files and other IOs
      run(*programs)
    end

    def reset!(with_stdlib? : Bool = @with_stdlib)
      @interpreter = Interpreter.new
      itself.use_stdios = @use_stdios.not_nil!
      if (@with_stdlib = with_stdlib?)
        prelude_require = Require.new(StringLiteral.new("stdlib/prelude.mt")).at(Location.new(__DIR__))
        @interpreter.run(prelude_require)      
      end
      self
    end

    # Helper method to quickly set all io to std or new
    def use_stdios=(@use_stdios : Bool)
      if @use_stdios
        itself.output  = STDOUT
        itself.input   = STDIN
        itself.errput  = STDERR
      else
        # If an io already not is an stdio, do not set a new
        itself.output = IO::Memory.new if itself.output == STDOUT
        itself.input  = IO::Memory.new if itself.input  == STDIN
        itself.errput = IO::Memory.new if itself.errput == STDERR
      end
    end

    def use_stdios!
      self.use_stdios = true
    end

    def use_stdios?
      @use_stdios.not_nil!
    end

    def program=(program)
      @program = 
        case program
        when .is_a? Expressions
          program
        when .is_a? Node
          program
        when .is_a? String
          Parser.for_content(program).parse
        when .is_a? IO
          Parser.new(program, (program.is_a?(File) ? program.path : "eval_input")).parse
        else # Might not be a good idea?
          Parser.for_content(program.to_s).parse
        end
    end    

    {% for itr_io in %w(output input errput) %}
      def {{itr_io.id}}
        @interpreter.{{itr_io.id}}
      end

      def {{itr_io.id}}=(io : IO)
        @interpreter.{{itr_io.id}} = io
        # Unless `io` is the relevant std `itr_io` 
        # `@use_stdios` (used in `#reset!`) should be set to false.
        unless io.same? {{("STD" + itr_io.gsub(/put/, "").upcase).id}}
          @use_stdios = false
        end
      end
    {% end %}
  end
end
