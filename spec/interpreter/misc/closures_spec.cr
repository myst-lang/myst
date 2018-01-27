require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Closures" do
  describe "on blocks" do
    it "captures the value of `self` as part of the closure" do
      itr = parse_and_interpret %q(
        @sum = 0
        [1, 2, 3].each{ |e| @sum += e }
        @sum
      )

      itr.stack.last.should eq(val(6))
    end

    it "can access variables from blocks on static methods (see #109)" do
      itr = parse_and_interpret %q(
        deftype Test
          defstatic hello(&block)
            block()
          end
        end

        i = 0
        Test.hello do
          i += 6
        end
        i
      )

      itr.stack.last.should eq(val(6))
    end

    it "can access variables from within nested blocks" do
      itr = parse_and_interpret %q(
        defmodule Test
          def hello(&block)
            block()
          end
        end

        i = 0
        Test.hello do
          [1, 2, 3].each{ |e| i += e }
        end
        i
      )

      itr.stack.last.should eq(val(6))
    end

    it "can access variables from within nested blocks on static methods (see #109)" do
      itr = parse_and_interpret %q(
        deftype Test
          defstatic hello(&block)
            block()
          end
        end

        i = 0
        Test.hello do
          [1, 2, 3].each{ |e| i += e }
        end
        i
      )

      itr.stack.last.should eq(val(6))
    end

    it "maintains the top level value of `self` from within nested blocks" do
      itr = parse_and_interpret %q(
        deftype Test
          defstatic hello(&block)
            block()
          end
        end

        @sum = 0
        Test.hello do
          [1, 2, 3].each{ |e| @sum += e }
        end
        @sum
      )

      itr.stack.last.should eq(val(6))
    end

    it "can access variables from a block within an anonymous function" do
      itr = parse_and_interpret %q(
        defmodule Test
          def hello(&block)
            block()
          end
        end

        i = 0

        func = fn
          ->() { [1, 2, 3].each{ |e| i += e }; i }
        end

        Test.hello(&func)
      )

      itr.stack.last.should eq(val(6))
    end

    it "can access variables from a block within an anonymous function on static methods (see #109)" do
      itr = parse_and_interpret %q(
        deftype Test
          defstatic hello(&block)
            block()
          end
        end

        i = 0

        func = fn
          ->() { [1, 2, 3].each{ |e| i += e }; i }
        end

        Test.hello(&func)
      )

      itr.stack.last.should eq(val(6))
    end
  end


  describe "on anonymous functions" do
    it "captures the value of `self` as part of the closure" do
      itr = parse_and_interpret %q(
        @sum = 0
        func = fn
          ->(a) { @sum += a }
        end

        func(6)
        @sum
      )

      itr.stack.last.should eq(val(6))
    end

    it "can access variables from anonymous functions on static methods (see #109)" do
      itr = parse_and_interpret %q(
        deftype Test
          defstatic hello(&block)
            block()
          end
        end

        i = 0
        Test.hello(&fn ->() { i += 6 } end)
        i
      )

      itr.stack.last.should eq(val(6))
    end

    it "can access variables from within a nested block" do
      itr = parse_and_interpret %q(
        defmodule Test
          def hello(&block)
            block()
          end
        end

        i = 0
        Test.hello do
          func = fn ->(e) { i += e } end
          [1, 2, 3].each(&func)
        end
        i
      )

      itr.stack.last.should eq(val(6))
    end

    it "can access variables from within a nested block on static methods (see #109)" do
      itr = parse_and_interpret %q(
        deftype Test
          defstatic hello(&block)
            block()
          end
        end

        i = 0
        Test.hello do
          func = fn ->(e) { i += e } end
          [1, 2, 3].each(&func)
        end
        i
      )

      itr.stack.last.should eq(val(6))
    end

    it "maintains the top level value of `self` from within a nested block" do
      itr = parse_and_interpret %q(
        deftype Test
          defstatic hello(&block)
            block()
          end
        end

        @sum = 0
        Test.hello do
          func = fn ->(e) { @sum += e } end
          [1, 2, 3].each(&func)
        end
        @sum
      )
    end
  end
end
