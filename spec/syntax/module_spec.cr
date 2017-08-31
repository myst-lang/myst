require "../spec_helper"

describe "Function Definition" do
  it "allows any valid constant as a name" do
    assert_valid %q(
      module AF_AF_ASF
      end
    )
  end

  it "is invalid with anything other than a constant for a name" do
    ["a", "baf24", "__fa1asf_1s"].each do |name|
      assert_invalid %Q(
        module #{name}
        end
      )
    end
  end

  it "is invalid with spaces in the name" do
    assert_invalid %q(
      module Bad Name
      end
    )
  end

  it "is invalid without a closing `end` keyword" do
    assert_invalid %q(
      module AModule
    )
  end

  it "is valid without parentheses with no parameters" do
    assert_valid %q(
      module AModule
      end
    )
  end

  it "should not have any tokens after the module name" do
    assert_invalid %q(
      module AModule()
      end
    )

    assert_invalid %q(
      module AModule[]
      end
    )
  end

  it "is valid with an empty body" do
    assert_valid %q(
      module AModule
      end
    )
  end

  it "is valid with expressions as a body" do
    assert_valid %q(
      module AModule
        a = 1
        b = 2
        a + b
      end
    )
  end

  it "is valid with function definitions as a body" do
    assert_valid %q(
      module AModule
        def some_func
        end

        def some_func2
        end
      end
    )
  end

  it "is valid with nested module definitions" do
    assert_valid %q(
      module AModule
        module Nested1
          module Nested2
          end
        end

        module Nested3
        end
      end
    )
  end

  it "is invalid with a newline before the module name" do
    assert_invalid %q(
      module
        NewlinedName
      end
    )
  end

  it "is valid with parenthetic expressions as the first body expression" do
    assert_valid %q(
      module AModule
        (thing1 + thing2)
      end
    )
  end
end

