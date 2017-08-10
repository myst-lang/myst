require "../spec_helper.cr"

describe "Integer Semantics" do
  it "understands equality" do
    assert_true %q(1 == 1)
    assert_true %q(5 == 5)
    assert_true %q(10 / 2 == 4 + 1)
  end

  it "understands inequality" do
    assert_true %q(1 != 2)
    assert_true %q(3 != 4)
    assert_true %q(10 / 2 != 3 + 1)
  end

  it "understands addition" do
    assert_true %q(1 + 1 == 2)
    assert_true %q(4 + 10 == 14)
  end

  it "understands subtraction" do
    assert_true %q(1 - 1 == 0)
    assert_true %q(10 - 4 == 6)
  end

  it "understands multiplication" do
    assert_true %q(1 * 1 == 1)
    assert_true %q(2 * 2 == 4)
    assert_true %q(14 * 10 == 140)
  end

  it "understands division" do
    assert_true %q(1 / 1 == 1)
    assert_true %q(2 / 2 == 1)
    assert_true %q(100 / 10 == 10)
  end

  it "truncates imperfect divison to an integer" do
    assert_true %q(1 / 2 == 0)
  end

  it "understands comparisons" do
    assert_true %q(1 < 2)
    assert_true %q(2 <= 2)
    assert_true %q(2 >= 2)
    assert_true %q(3 > 2)
  end

  describe "in operations with Floats" do
    it "yields a float after addition" do
      assert_true %q(1 + 1.0 == 2.0)
      assert_true %q(1 + 1.0 != 2)
    end

    it "yields a float after subtraction" do
      assert_true %q(1 - 1.0 == 0.0)
      assert_true %q(1 - 1.0 != 0)
    end

    it "yields a float after multiplication" do
      assert_true %q(1 * 5.0 == 5.0)
      assert_true %q(1 * 1.0 != 5)
    end

    it "yields a float after division" do
      assert_true %q(1 - 1.0 == 0.0)
      assert_true %q(1 - 1.0 != 0)
    end

    it "does not truncate division with a float" do
      assert_true %q(10 / 4.0 == 2.5)
    end

    it "maintains comparison properties" do
      assert_true %q(1 < 2.0)
      assert_true %q(2 <= 2.0)
      assert_true %q(2 >= 2.0)
      assert_true %q(3 > 2.0)
    end
  end
end
