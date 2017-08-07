require "../spec_helper"

describe "Require" do
  it "is invalid without an argument" do
    assert_invalid %q(require)
  end

  it "is valid with a single argument" do
    assert_valid %q(require "some_path")
  end

  it "is invalid with multiple arguments" do
    assert_invalid %q(require "some_path", "another_path")
  end

  it "accepts expressions as arguments" do
    assert_valid %q(require base + path)
  end

  it "allows newlines before the argument" do
    assert_valid %q(
      require
        "disallowed"
    )
  end
end

