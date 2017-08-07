require "../spec_helper"

describe "Function Definition" do
  it "allows any valid identifier as a name" do
    ["a", "baf24", "__fa1asf_1s", "AF_AF_ASF"].each do |name|
      assert_valid %Q(
        def #{name}
        end
      )
    end
  end

  it "is valid without parentheses with no parameters" do
    assert_valid %q(
      def some_func
      end
    )
  end

  it "is valid with parentheses but no parameters" do
    assert_valid %q(
      def some_func()
      end
    )
  end

  it "is valid with one parameter" do
    assert_valid %q(
      def some_func(param1)
      end
    )
  end

  it "is valid with multiple parameters" do
    assert_valid %q(
      def some_func(param1, param2)
      end
    )
  end

  it "is valid with no body" do
    assert_valid %q(
      def some_func
      end
    )
  end

  it "is valid with one expression in the body" do
    assert_valid %q(
      def two
        1 + 1
      end
    )
  end

  it "is valid with multiple expressions in the body" do
    assert_valid %q(
      def some_func
        a = 1
        b = 2
        a + b
      end
    )
  end
end
