require "../spec_helper.cr"
require "../support/breakpoints.cr"

describe "Interpreter - Callstack" do
  it "is empty when no calls have occurred" do
    itr = parse_and_interpret %q(
      true
      false
      nil
    )

    itr.callstack.size.should eq(0)
  end

  it "is empty after all calls in a program have completed" do
    itr = parse_and_interpret %q(
      def bar; nil; end
      def foo; bar; end
      def baz; foo; end

      baz
    )

    itr.callstack.size.should eq(0)
  end


  describe "when entering a function call" do
    it "adds an entry to the callstack" do
      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        # `breakpoint` is added as a method, so calling the breakpoint itself
        # should push an entry onto the callstack, resulting in 2 entries
        # including `foo`.
        itr.callstack.size.should eq(2)
      end

      parse_and_interpret! %q(
        def foo
          breakpoint
        end

        foo
      ), interpreter: itr
    end

    it "uses the location of the callsite" do
      def_location = Location.new("def_location")
      call_location = Location.new("call_location")
      clause = Def.new("foo", body: Call.new(nil, "breakpoint").at(call_location)).at(def_location)

      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        itr.callstack.last.location.should eq(call_location)
      end

      itr.run(clause)
      parse_and_interpret! %q(
        foo
      ), interpreter: itr
    end

    it "uses the real name of the function being called" do
      clause = Def.new("foo", body: Call.new(nil, "breakpoint"))

      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        itr.callstack.first.name.should eq("foo")
        itr.callstack.last.name.should eq("breakpoint")
      end

      itr.run(clause)
      parse_and_interpret! %q(
        foo
      ), interpreter: itr
    end
  end


  describe "when leaving a function call normally" do
    it "removes the last entry from the callstack" do
      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        itr.callstack.size.should eq(__args[0])
      end

      parse_and_interpret! %q(
        def foo
          breakpoint(2)
        end

        breakpoint(1)
        foo
        breakpoint(1)
      ), interpreter: itr
    end

    describe "with an explicit return" do
      it "removes the last entry from the callstack" do
        itr = Interpreter.new
        add_breakpoint(itr, "breakpoint") do
          itr.callstack.size.should eq(__args[0])
        end

        parse_and_interpret! %q(
          def foo
            return true
          end

          foo
          breakpoint(1)
        ), interpreter: itr
      end
    end
  end


  describe "when leaving a block via a `break`" do
    it "removes the `block` from the callstack" do
      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        itr.callstack.size.should eq(__args[0])
      end

      parse_and_interpret! %q(
        [1, 2, 3].each{ |e| breakpoint(2) }
        breakpoint(1)
      ), interpreter: itr
    end
  end


  describe "when leaving a block via a `next`" do
    it "removes the `next` from the callstack" do
      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        itr.callstack.size.should eq(__args[0])
      end

      parse_and_interpret! %q(
        def foo(&block)
          x = 1
          while x < 3
            block(x)
            breakpoint(2)
            x += 1
          end
        end

        foo{ |e| breakpoint(3) }
      ), interpreter: itr
    end
  end


  describe "when encountering a `raise`" do
    it "pushes the raise callsite onto the callstack" do
      itr = interpret_with_mocked_output %q(
        raise "something"
      )

      itr.callstack.size.should eq(1)
      itr.callstack.last.name.should eq("raise")
    end
  end


  describe "when handling a `raise` with a `rescue`" do
    it "pushes the rescue block location onto the callstack" do
      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        itr.callstack[itr.callstack.size-2].name.should eq("rescue")
      end

      parse_and_interpret! %q(
        def foo
          raise nil
        rescue
          breakpoint
        end

        foo
      ), interpreter: itr
    end

    it "does not push rescue blocks that do not match the exception" do
      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        itr.callstack.context.map(&.name).should eq(["bar", "foo", "raise", "rescue", "breakpoint"])
        itr.callstack.size.should eq(5)
      end

      parse_and_interpret! %q(
        def foo
          raise nil
        rescue :not_nil
        end

        def bar
          foo
        rescue
          breakpoint
        end

        bar
      ), interpreter: itr
    end

    it "pops both the rescue and the raise when leaving the rescue normally" do
      itr = Interpreter.new

      parse_and_interpret! %q(
        def foo
          raise nil
        rescue
          nil
        end

        foo
      ), interpreter: itr

      itr.callstack.size.should eq(0)
    end

    it "pops the rescue before moving to an ensure block" do
      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        itr.callstack.size.should eq(3)
        itr.callstack.context.map(&.name).should eq(["foo", "ensure", "breakpoint"])
      end

      parse_and_interpret! %q(
        def foo
          raise nil
        rescue
          nil
        ensure
          breakpoint
        end

        foo
      ), interpreter: itr
    end
  end


  describe "when handling an `ensure`" do
    it "pushes the ensure block onto the callstack" do
      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        itr.callstack[itr.callstack.size-2].name.should eq("ensure")
      end

      parse_and_interpret! %q(
        def foo
          raise nil
        ensure
          breakpoint
        end

        def bar
          foo
        rescue
          nil
        end

        bar
      ), interpreter: itr
    end

    it "pops the ensure block when leaving normally" do
      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
      end

      parse_and_interpret! %q(
        def foo
        ensure
          nil
        end

        foo
      ), interpreter: itr

      itr.callstack.size.should eq(0)
    end
  end


  describe "when raising an error from an exception handler" do
    it "leaves the rescue on the stack" do
      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        itr.callstack.context.map(&.name).should eq([
          "bar",
          "foo",
          "raise",
          "rescue",
          "raise",
          "rescue",
          "breakpoint"
        ])
      end

      parse_and_interpret! %q(
        def foo
          raise :one
        rescue
          raise :two
        end

        def bar
          foo
        rescue :two
          breakpoint
        end

        bar
      ), interpreter: itr
    end

    it "leaves the ensure on the stack" do
      itr = Interpreter.new
      add_breakpoint(itr, "breakpoint") do
        itr.callstack.context.map(&.name).should eq([
          "bar",
          "foo",
          "ensure",
          "raise",
          "rescue",
          "breakpoint"
        ])
      end

      parse_and_interpret! %q(
        def foo
        ensure
          raise :two
        end

        def bar
          foo
        rescue :two
          breakpoint
        end

        bar
      ), interpreter: itr
    end
  end
end
