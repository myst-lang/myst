require "../spec_helper"

describe "Function Call" do
  it "allows any valid identifier as a name" do
    ["a", "baf24", "__fa1asf_1s", "AF_AF_ASF"].each do |name|
      assert_valid %Q(#{name}())
    end
  end

  it "is valid with parentheses but no arguments" do
    assert_valid %q(some_func())
  end

  it "is valid with one parameter" do
    assert_valid %q(some_func(param1))
  end

  it "is valid with multiple parameters" do
    assert_valid %q(some_func(param1, param2, param3))
  end

  describe "with a block" do
    it "is valid without block params" do
      assert_valid %q(
        some_func() do
        end
      )
    end

    it "is valid with block params" do
      assert_valid %q(
        some_func() do |x, y|
        end
      )
    end

    it "is valid with a single-expression body" do
      assert_valid %q(
        some_func() do |x, y|
          1 + 1
        end
      )
    end

    it "is valid with a multi-expression body" do
      assert_valid %q(
        some_func() do |x, y|
          a = 1
          b = 1
          a + b
        end
      )
    end

    it "is valid with block param section without params" do
      assert_valid %q(
        some_func() do ||
        end
      )
    end

    it "is invalid when block params start on a new line" do
      assert_invalid %q(
        some_func() do
          |newlined_params|
        end
      )
    end

    it "is valid with params on multiple lines" do
      assert_valid %q(
        some_func() do |param1,
                        param2,
                        param3|
        end
      )
    end
  end
end

