require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

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
          rescue Float
            @rescued_float = true
          rescue String
            @rescued_string = true
          rescue
            @rescued_other = true
          end

          foo
        )

        itr.current_self.ivars.has_key?("@rescued_string").should be_true
        itr.current_self.ivars.has_key?("@rescued_float").should  be_false
        itr.current_self.ivars.has_key?("@rescued_other").should  be_false
      end

      it "performs type restriction when given" do
        itr = interpret_with_mocked_output %q(
          def foo
            raise "an error"
          rescue err : String
            @message = err
          end

          foo
        )

        itr.current_self.ivars["@message"].should eq(val("an error"))
      end

      it "performs pattern and name matching when given" do
        itr = interpret_with_mocked_output %q(
          def foo
            raise [1, 2]
          rescue [a, b] =: list
            @sum = a + b
            @list = list
          end

          foo
        )

        itr.current_self.ivars["@sum"].should   eq(val(3))
        itr.current_self.ivars["@list"].should  eq(val([1,2]))
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

    it "restores `self` when rescuing from a `raise` (see #59)" do
      itr = interpret_with_mocked_output %q(
        defmodule Foo
          def run(&block)
            block()
            nil
          rescue failure
            do_rescue
          end

          def do_rescue
            :saved
          end
        end

        Foo.run do
          [1, 2, 3].each{ |e| raise :woops }
        end
      )

      itr.errput.to_s.should  eq("")
      itr.stack.last.should   eq(val(:saved))
    end

    it "restores scope overrides after rescuing (see #95)" do
      itr = interpret_with_mocked_output %q(
        def inner
          raise "woops"
        end

        def do_run
          inner
        rescue "woops"
          :rescued
        end


        list = []
        [1, 2, 3].each do |num|
          # `self` reference
          do_run
          # local scope reference
          num
          # parent scope reference
          list
        end

        :finished
      )

      itr.errput.to_s.should  eq("")
      itr.stack.last.should   eq(val(:finished))
    end
  end

  describe "`ensure`" do
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

    it "is executed when an exception is raised, but not rescued by handler" do
      itr = interpret_with_mocked_output %q(
        @rescued = false
        @ensured = false

        def foo
          raise "an error"
        rescue Integer
          @rescued = true
        ensure
          @ensured = true
        end

        foo
      )

      itr.current_self.ivars["@rescued"].should eq(val(false))
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

    it "restores `self` before executing (see #59)" do
      itr = parse_and_interpret %q(
        defmodule Foo
          def run(&block)
            @ensured = false
            block()
            nil
          ensure
            do_ensure
          end

          def do_ensure
            @ensured = true
          end

          def ensured?
            @ensured
          end
        end

        Foo.run do
          [1, 2, 3].each{ |e| raise :woops }
        rescue
          # the `raise` will not be rescued by `run`.
          nil
        end

        Foo.ensured?
      )

      itr.stack.last.should eq(val(true))
    end
  end
end
