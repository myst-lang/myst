require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - AnonymousFunction" do
  it "places a Functor object on the stack" do
    itr = parse_and_interpret %q(
      fn
        ->(a) { a + 1 }
      end
    )

    functor = itr.stack.pop.as(TFunctor)
    functor.clauses.size.should eq(1)
  end

  it "acts like a closure" do
    itr = parse_and_interpret %q(
      fn
        ->(a) { a + 1 }
      end
    )

    functor = itr.stack.pop.as(TFunctor)
    functor.closure?.should eq(true)
  end

  it "allows clauses of various arities" do
    itr = parse_and_interpret %q(
      fn
        ->(a) { a * 2 }
        ->(a, b) { a + b }
        ->(a, b, c) { a + b - c }
      end
    )

    functor = itr.stack.pop.as(TFunctor)
    functor.clauses.size.should eq(3)
    functor.clauses.first.as(TFunctorDef).params.size.should eq(1)
    functor.clauses.last .as(TFunctorDef).params.size.should eq(3)
  end


  it "does not create an entry in the current scope" do
    itr = Interpreter.new()
    itr.current_scope.clear

    parse_and_interpret %q(
      fn
        ->(a) { a + 1 }
      end
    ), interpreter: itr

    itr.current_scope.values.size.should eq(0)
  end

  it "can be assigned to a local variable" do
    itr = parse_and_interpret %q(
      foo = fn
        ->(a) { a + 1 }
      end
    )

    itr.current_scope["foo"].class.should eq(TFunctor)
  end
end
