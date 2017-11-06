require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - OpAssign" do
  # Normal OpAssigns are all handled identically. The exceptions are
  # conditional assignments, `||=` and `&&=`. These will be tested later on.
  ["+=", "-=", "*=", "/=", "%="].each do |op|
    describe op do
      it "cannot assign to a literal value" do
        # This is already asserted by the parser. It is simply repeated here for
        # completeness.
        expect_raises{ parse_and_interpret %Q(false #{op} 1) }
      end


      it "does not allow assignment to non-existant values" do
        itr = interpret_with_mocked_output %Q(a #{op} 2)
        itr.errput.to_s.downcase.should match(/no variable or method `a`/)
      end

      it "does not allow re-assignment to constants" do
        error = expect_raises do
          parse_and_interpret %Q(
            THING = 1
            THING #{op} 2
          )
        end

        (error.message || "").downcase.should match(/re-assignment/)
      end
    end
  end


  # Conditional assignments flip the rewritten from `a = a op b` to
  # `a op a = b`. The logical semantics then act as normal.
  describe "||=" do
    it "assigns the target if it is currently `nil`" do
      itr = parse_and_interpret %q(
        a = nil
        a ||= 1
        a
      )

      itr.stack.pop.should eq(val(1))
    end

    it "does not assign the target if it is not `nil`" do
      itr = parse_and_interpret %q(
        a = 1
        a ||= 2
        a
      )

      itr.stack.pop.should eq(val(1))
    end

    it "does not visit the value if the target is not `nil`" do
      itr = parse_and_interpret %q(
        @was_called = false
        def foo
          @was_called = true
        end

        a = 1
        a ||= foo
        @was_called
      )

      itr.stack.pop.should eq(val(false))
    end

    it "assigns new ivars" do
      itr = parse_and_interpret %q(
        @a ||= 1
        @a
      )

      itr.stack.pop.should eq(val(1))
    end

    it "assigns new vars" do
      itr = parse_and_interpret %q(
        a ||= 1
        a
      )

      itr.stack.pop.should eq(val(1))
    end

    it "assigns new underscores" do
      itr = parse_and_interpret %q(
        _a ||= 1
        _a
      )

      itr.stack.pop.should eq(val(1))
    end

    it "assigns new constants" do
      itr = parse_and_interpret %q(
        THING ||= 1
        THING
      )

      itr.stack.pop.should eq(val(1))
    end

    describe "with a Call target" do
      it "calls the assignment method when assigning" do
        itr = parse_and_interpret %q(
          deftype Foo
            def a; @a; end
            def a=(other); @a = other; end
          end

          f = %Foo{}
          f.a = nil
          f.a ||= 2
          f.a
        )

        itr.stack.pop.should eq(val(2))
      end


      it "does not visit the value if the call result is truthy" do
        itr = parse_and_interpret %q(
          deftype Foo
            def a; @a; end
            def a=(other); @a = other; end
          end

          @called = false
          def not_called
            @called = true
          end

          f = %Foo{}
          f.a = 2
          f.a ||= not_called
          @called
        )

        itr.stack.pop.should eq(val(false))
      end
    end
  end

  describe "&&=" do
    it "assigns the target if it is currently truthy" do
      itr = parse_and_interpret %q(
        a = 1
        a &&= 2
        a
      )

      itr.stack.pop.should eq(val(2))
    end

    it "does not assign the target if it is not truthy" do
      itr = parse_and_interpret %q(
        a = nil
        a &&= 2
        a
      )

      itr.stack.pop.should eq(val(nil))
    end

    it "does not visit the value if the target is not truthy" do
      itr = parse_and_interpret %q(
        @was_called = false
        def foo
          @was_called = true
        end

        a = nil
        a &&= foo
        @was_called
      )

      itr.stack.pop.should eq(val(false))
    end

    it "assigns new ivars as nil" do
      itr = parse_and_interpret %q(
        @a &&= 1
        @a
      )

      itr.stack.pop.should eq(val(nil))
    end

    it "assigns new vars as nil" do
      itr = parse_and_interpret %q(
        a &&= 1
        a
      )

      itr.stack.pop.should eq(val(nil))
    end

    it "assigns new underscores as nil" do
      itr = parse_and_interpret %q(
        _a &&= 1
        _a
      )

      itr.stack.pop.should eq(val(nil))
    end

    it "assigns new constants as nil" do
      itr = parse_and_interpret %q(
        THING &&= 1
        THING
      )

      itr.stack.pop.should eq(val(nil))
    end

    describe "with a Call target" do
      it "calls the assignment method when assigning" do
        itr = parse_and_interpret %q(
          deftype Foo
            def a; @a; end
            def a=(other); @a = other; end
          end

          f = %Foo{}
          f.a = 1
          f.a &&= 2
          f.a
        )

        itr.stack.pop.should eq(val(2))
      end


      it "does not visit the value if the call result is truthy" do
        itr = parse_and_interpret %q(
          deftype Foo
            def a; @a; end
            def a=(other); @a = other; end
          end

          @called = false
          def not_called
            @called = true
          end

          f = %Foo{}
          f.a = nil
          f.a &&= not_called
          @called
        )

        itr.stack.pop.should eq(val(false))
      end
    end
  end

end
