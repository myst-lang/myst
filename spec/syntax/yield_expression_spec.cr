require "../spec_helper"

macro test_yield(context, before, after)
  describe {{context}} do
    it "is valid with no arguments" do
      assert_valid %q(
        {{before}}
          yield
        {{after}}
      )
    end

    it "is valid with a single argument" do
      assert_valid %q(
        {{before}}
          yield(x)
        {{after}}
      )
    end

    it "is valid with multiple arguments" do
      assert_valid %q(
        {{before}}
          yield(x, y)
        {{after}}
      )
    end

    it "can be a right-hand-side expression" do
      assert_valid %q(
        {{before}}
          result = yield
          result = yield(x)
          result = yield(x, y)
        {{after}}
      )
    end

    it "can be called multiple times" do
      assert_valid %q(
        {{before}}
          yield(x)
          yield(y)
        {{after}}
      )
    end

    it "can be used as the receiver of a postfix expression" do
      assert_valid %q(
        {{before}}
          yield[1]
          yield().member
          yield(x, y)()
        {{after}}
      )
    end

    it "requires parentheses when the receiver in a call expression" do
      assert_valid %q(
        {{before}}
          yield()(x, y)
        {{after}}
      )
    end
  end
end


describe "Yield Expression" do
  test_yield "in function definition", before: "def some_func(x, y)", after: "end"
  test_yield "in block definition", before: "some_func() do |x, y|", after: "end"
end

