require "./spec_helper.cr"

describe "VM -" do
  describe "Constructors:" do
    it "Returns a empty vm ready for use when no args provided" do
      vm = VM.new(with_stdlib?: false)
      vm.should be_truthy
      vm.interpreter.should be_a Interpreter
    end

    it "Takes a single string as a program" do
      vm = VM.eval "IO.print(1 + 2)", with_stdlib?: false
      vm.output.to_s.should eq "3"
    end

    it "Can be created with a file" do
      VM.for_file "spec/support/requirable/foo_defs.mt", with_stdlib?: false
    end

    it "raises a parse error when an invalid program is passed" do
      expect_raises ParseError do
        VM.eval("Invalid-program-4life", with_stdlib?: false)
      end
    end

    it "raises a semantic error when a semantically-invaled program is passed" do
      expect_raises Semantic::Error do
        VM.eval("def foo(a, a); end", with_stdlib?: false)
      end
    end
  end

  describe "IOs:" do
    it "can be changed after initialization" do
      vm = VM.for_content %q<IO.puts("Hello")>, with_stdlib?: false
      vm.run
      vm.output.to_s.should eq("Hello\n")

      vm.output = IO::Memory.new
      vm.run
      vm.output.to_s.should eq("Hello\n")
    end

    it "A VM has its very own ios by default" do
      vm = VM.new(with_stdlib?: false)
      {% for io in %w(output input errput) %}
        vm.{{io.id}}.should be_a IO

        # The ios are by default supposed not to be the stdios.
        # Lazy hack for getting `STDIN`, `STDERR`, etc, from `"input"`, `"errput"`, etc
        # I mean, thats the whole point of macros right? Its awesome :D
        vm.{{io.id}}.should_not be {{("STD" + io.gsub(/put/, "").upcase).id}}
      {% end %}
    end

    it "can be reset to use STDIO with #use_stdios" do
      vm = VM.new(with_stdlib?: false)

      # Changes all IOs to the stdios
      vm.use_stdios!
      {% for io in %w(output input errput) %}
        # See the previous `it`
        vm.{{io.id}}.should be {{("STD" + io.gsub(/put/, "").upcase).id}}
      {% end %}

      sentence = "Fishy fishes are cool"

      # This should not be changed
      vm.output = IO::Memory.new sentence

      # Sets all IOs that are std's to new `IO::Memory`s
      vm.use_stdios = false

      {% for io in %w(output input errput) %}
        vm.{{io.id}}.should_not be {{("STD" + io.gsub(/put/, "").upcase).id}}
      {% end %}

      vm.output.to_s.should eq sentence
    end

    it "Has a method telling if its using stdios or not" do
      vm = VM.new(with_stdlib?: false)
      vm.use_stdios?.should be_false
      vm.use_stdios!
      vm.use_stdios?.should be_true
    end
  end

  describe "Running myst code:" do
    it "Works" do
      vm = VM.new(with_stdlib?: false)

      # defines `foo(a, b); a + b; end`
      vm.require "spec/support/requirable/foo_defs.mt"
      vm.eval "IO.print(foo(1, 2))"

      vm.output.to_s.should eq "3"
    end

    it "Works in steps" do
      vm = VM.new(with_stdlib?: false)

      vm.eval <<-MYST_PROG
      def hello()
        IO.puts("Hello")
      end
      MYST_PROG

      vm.eval %q<hello()>

      person = "Bob"
      vm.eval <<-MYST_PROG
      def hello(person)
        IO.puts("Hello <(person)>")
      end
      MYST_PROG

      vm.eval %<hello("#{person}")>

      vm.output.to_s.should eq "Hello\nHello #{person}\n"
    end

    it "Has a `#program` property that is the program run with `#run` without arguments, and it can be changed" do
      vm = VM.for_content %q<IO.puts("Hello")>, with_stdlib?: false
      vm.run
      vm.program = %q<IO.puts("Bye")>
      vm.run
      vm.output.to_s.should eq "Hello\nBye\n"
    end

    it "Has a `#print_ast` method for debugging" do
      vm = VM.for_content %q<IO.puts("Hello world!")>, with_stdlib?: false
      output = IO::Memory.new
      vm.print_ast output
      output.to_s.should eq "Expressions\nCall\nConst\nStringLiteral|Hello world!\n"
    end

    describe "#run(*programs)" do
      it "takes files, filepaths or IOs; and (attempts to) run them" do
        file = File.open "spec/support/requirable/foo_defs.mt"
        vm = VM.new

        vm.run IO::Memory.new(%q<IO.puts(1)>)
        vm.run file
        vm.eval %q<IO.puts(foo(1, 2))>

        vm.output.to_s.should eq "1\n3\n"
      end

      it "throws a ParseError when invalid code is attempted to be runned" do
        vm = VM.new(with_stdlib?: false)
        expect_raises ParseError do
          vm.run IO::Memory.new %q<Hello there>
        end

        expect_raises ParseError do
          vm.run "spec/support/requirable/invalid_code.mt"
        end

        expect_raises ParseError do
          vm.run File.open "spec/support/requirable/invalid_code.mt"
        end
      end
    end
  end

  describe "#reset!" do
    it "resets all IOs, and the interpreter" do
      vm = VM.new(with_stdlib?: false)

      vm.eval %q<IO.puts("I will be gone")>

      vm.output.to_s.empty?.should be_false
      vm.reset!
      vm.output.to_s.empty?.should be_true

      vm.eval "IO.puts(to_bob()[:fish])"
      vm.errput.to_s.includes?("No variable or method `to_bob` for Kernel").should be_true
    end

    it "takes a parameter that decides wether to use the stdlib or not" do
      vm = VM.new
      vm.eval %q<3.times { IO.puts(Random.rand()) }>
      vm.errput.to_s.empty?.should be_true

      vm.reset! false

      vm.eval %q<3.times { IO.puts(Random.rand()) }>
      vm.errput.to_s.includes?("No variable or method `times`").should be_true
    end
  end
end
