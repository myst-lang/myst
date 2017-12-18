require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - IO Methods" do
  describe "#puts" do
    it "with no argument, prints a newline to the output" do
      itr = interpret_with_mocked_output %q(
        IO.puts
      )

      itr.output.to_s.should eq("\n")
    end

    it "with one argument, prints the argument followed by a newline" do
      itr = interpret_with_mocked_output %q(
        IO.puts(1)
      )

      itr.output.to_s.should eq("1\n")
    end

    it "with multiple arguments, prints each argument on a newline" do
      itr = interpret_with_mocked_output %q(
        IO.puts(1, 2, 3)
      )

      itr.output.to_s.should eq("1\n2\n3\n")
    end

    it "calls `to_s` on each argument to determine output contents" do
      itr = interpret_with_mocked_output %q(
        deftype Foo
          def to_s
            "called to_s"
          end
        end
        IO.puts(%Foo{})
      )

      itr.output.to_s.should eq("called to_s\n")
    end

    it "raises an error if `to_s` for an object does not return a String" do
      itr = interpret_with_mocked_output %q(
        deftype Foo
          def to_s
            nil
          end
        end
        IO.puts(%Foo{})
      )

      itr.errput.to_s.should match(/expected String argument/)
      itr.output.to_s.should eq("")
    end
  end

  describe "#print" do
    it "with no argument, prints a null byte to the output" do
      itr = interpret_with_mocked_output %q(
        IO.print
      )

      itr.output.to_s.should eq("")
    end

    it "with one argument, prints the argument" do
      itr = interpret_with_mocked_output %q(
        IO.print(1)
      )

      itr.output.to_s.should eq("1")
    end

    it "with multiple arguments, prints each argument" do
      itr = interpret_with_mocked_output %q(
        IO.print(1, 2, 3)
      )

      itr.output.to_s.should eq("123")
    end

    it "calls `to_s` on each argument to determine output contents" do
      itr = interpret_with_mocked_output %q(
        deftype Foo
          def to_s
            "called to_s"
          end
        end
        IO.print(%Foo{})
      )

      itr.output.to_s.should eq("called to_s")
    end

    it "raises an error if `to_s` for an object does not return a String" do
      itr = interpret_with_mocked_output %q(
        deftype Foo
          def to_s
            nil
          end
        end
        IO.print(%Foo{})
      )

      itr.errput.to_s.should match(/expected String argument/)
      itr.output.to_s.should eq("")
    end
  end

  describe "#gets" do
    it "no input" do
      itr = interpret_with_mocked_input %q(
        IO.gets
      ), nil

      itr.stack.pop.should eq(val(nil))
    end

    it "a string from the IO" do
      itr = interpret_with_mocked_input %q(
        IO.gets               
      ), "hello, world"

      itr.stack.pop.should eq(val("hello, world"))
    end

    it "multiple inputs from the IO" do
      itr = interpret_with_mocked_input %q(
        IO.gets
        IO.gets         
      ), "hello, world\nhello, again\n"

      itr.stack.pop.should eq(val("hello, again"))
    end
  end
end
