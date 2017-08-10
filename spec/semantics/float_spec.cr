require "../spec_helper.cr"

describe "Float Semantics" do
  it "understands equality" do
    assert_true %q(1.0 == 1.0)
    assert_true %q(5.0 == 5.0)
    assert_true %q(10.0 / 2.0 == 3.4 + 1.6)
  end

  it "understands inequality" do
    assert_true %q(1.0 != 2.0)
    assert_true %q(3.0 != 3.1)
    assert_true %q(10.0 / 2.0 != 3.0 + 1.0)
  end

  it "is always truthy" do
    assert_truthy %q(1.0)
    assert_truthy %q(0.0)
    assert_truthy %q(150.252)
  end

  it "understands addition" do
    assert_true %q(1.0 + 1.0 == 2.0)
    assert_true %q(4.0 + 10.0 == 14.0)
  end

  it "understands subtraction" do
    assert_true %q(1.0 - 1.0 == 0.0)
    assert_true %q(10.0 - 4.0 == 6.0)
  end

  it "understands multiplication" do
    assert_true %q(1.0 * 1.0 == 1.0)
    assert_true %q(2.5 * 4.0 == 10.0)
    assert_true %q(14.3 * 10.0 == 143.0)
  end

  it "understands division" do
    assert_true %q(1.0 / 1.0 == 1.0)
    assert_true %q(2.0 / 2.0 == 1.0)
    assert_true %q(100.0 / 10.0 == 10.0)
  end

  it "does not truncate imperfect divison" do
    assert_true %q(1.0 / 2.0 == 0.5)
  end

  it "understands comparisons" do
    assert_true %q(1.0 < 2.0)
    assert_true %q(2.0 <= 2.0)
    assert_true %q(2.0 >= 2.0)
    assert_true %q(3.0 > 2.0)
  end

  describe "in operations with Integers" do
    it "yields a float after addition" do
      assert_true %q(1.0 + 1 == 2.0)
      assert_true %q(1.0 + 1 != 2)
    end

    it "yields a float after subtraction" do
      assert_true %q(1.0 - 1 == 0.0)
      assert_true %q(1.0 - 1 != 0)
    end

    it "yields a float after multiplication" do
      assert_true %q(1.0 * 5 == 5.0)
      assert_true %q(1.0 * 1 != 5)
    end

    it "yields an integer after division" do
      assert_true %q(1.0 - 1 == 0.0)
      assert_true %q(1.0 - 1 != 0)
    end

    it "does not truncate division" do
      assert_true %q(10.0 / 4 == 2.5)
    end

    it "maintains comparison properties" do
      assert_true %q(1 < 2.0)
      assert_true %q(2 <= 2.0)
      assert_true %q(2 >= 2.0)
      assert_true %q(3 > 2.0)
    end
  end
end
