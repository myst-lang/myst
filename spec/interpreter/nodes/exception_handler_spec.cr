require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

private def interpret_with_mocked_output(source)
  itr = Interpreter.new(output: IO::Memory.new, errput: IO::Memory.new)
  parse_and_interpret(source, itr)
end

private def it_raises(source, error)
  it "raises `#{error}` from `#{source}`" do
    itr = interpret_with_mocked_output(source)
    itr.errput.to_s.should contain(error)
  end
end

describe "Interpreter - ExceptionHandler" do
  describe "`rescue`" do
    describe "with no argument" do
      it "captures all exceptions" do
        itr = interpret_with_mocked_output %q(
          def foo
            raise "an error"
          rescue
            :rescued
          end

          foo
        )

        itr.stack.pop.should eq(val(:rescued))
        itr.errput.to_s.size.should eq(0)
      end

      it "stops propogation of exceptions" do
        itr = interpret_with_mocked_output %q(
          def inner
            raise "an error"
          rescue
            :rescued_inner
          end

          def outer
            inner
          rescue
            :rescued_outer
          end

          outer
        )

        itr.stack.pop.should eq(val(:rescued_inner))
      end
    end

    describe "with an argument" do
      it "is only executed when the exception matches the argument" do
        itr = interpret_with_mocked_output %q(
          def foo
            raise "an error"
          rescue Integer
            @rescued_integer = true
          rescue
            @rescued_other = true
          end

          foo
        )

        itr.current_self.ivars.has_key?("@rescued_integer").should be_false
        itr.current_self.ivars.has_key?("@rescued_other").should be_true
      end

      it "makes named parameters available in the rescue scope" do
        itr = interpret_with_mocked_output %q(
          def foo
            raise "an error"
          rescue err
            @rescued_value = err
          end

          foo
        )

        itr.current_self.ivars.has_key?("@rescued_value").should be_true
        itr.current_self.ivars["@rescued_value"].should eq(val("an error"))
      end

      it "makes pattern-matched variables available in the rescue scope" do
        itr = interpret_with_mocked_output %q(
          def foo
            raise {a: 1, b: 2}
          rescue {a: a, b: b}
            @matched_values = [a, b]
          end

          foo
        )

        itr.current_self.ivars.has_key?("@matched_values").should be_true
        itr.current_self.ivars["@matched_values"].should eq(val([1, 2]))
      end
    end
  end


  describe "ensure" do
    it "is executed after rescuing an exception" do
      itr = parse_and_interpret %q(
        @rescued = false
        @ensured = false

        def foo
          raise "an error"
        rescue
          @rescued = true
        ensure
          @ensured = true
        end

        foo
      )

      itr.current_self.ivars["@rescued"].should eq(val(true))
      itr.current_self.ivars["@ensured"].should eq(val(true))
    end

    it "is executed when no exception is raised" do
      itr = parse_and_interpret %q(
        @ensured = false

        def foo
        ensure
          @ensured = true
        end

        foo
      )

      itr.current_self.ivars["@ensured"].should eq(val(true))
    end

    it "does not change the return value of the block" do
      itr = parse_and_interpret %q(
        @ensured = false

        def foo
          :unchanged
        ensure
          @ensured = true
        end

        foo
      )

      itr.stack.pop.should eq(val(:unchanged))
      itr.current_self.ivars["@ensured"].should eq(val(true))
    end
  end
end
