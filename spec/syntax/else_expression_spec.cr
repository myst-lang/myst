require "../spec_helper.cr"

describe "Else Expression" do
  it "is invalid as a standalone expression" do
    assert_invalid %q(
      else
      end
    )
  end

  it "is invalid when following a looping conditional" do
    assert_invalid %q(
      while true
      else
      end
    )
  end

  describe "when following an `if` block" do
    it "is valid with an empty body" do
      assert_valid %q(
        if false
        else
        end
      )
    end

    it "is valid with a single-expression body" do
      assert_valid %q(
        if true
        else
          1 + 1
        end
      )
    end

    it "is valid with a multi-expression body" do
      assert_valid %q(
        if true
        else
          a = 1
          b = 1
          a + b
        end
      )
    end

    it "allows a single expression immediately following the `else`" do
      assert_valid %q(
        if false
        else wrong end
      )
    end

    it "is invalid with a succeeding conditional block" do
      assert_invalid %q(
        if false
        else
        elif wrong
        end
      )
    end
  end


  describe "when following an `elif` block" do
    it "is valid with an empty body" do
      assert_valid %q(
        if false
        elif false
        else
        end
      )
    end

    it "is valid with a single-expression body" do
      assert_valid %q(
        if true
        elif true
        else
          1 + 1
        end
      )
    end

    it "is valid with a multi-expression body" do
      assert_valid %q(
        if true
        elif true
        else
          a = 1
          b = 1
          a + b
        end
      )
    end

    it "allows a single expression immediately following the `else`" do
      assert_valid %q(
        if false
        elif false
        else wrong end
      )
    end

    it "is invalid with a succeeding conditional block" do
      assert_invalid %q(
        if false
        elif wrong
        else
        elif wrong
        end
      )
    end
  end


  describe "when following an `unless` block" do
    it "is valid with an empty body" do
      assert_valid %q(
        unless false
        else
        end
      )
    end

    it "is valid with a single-expression body" do
      assert_valid %q(
        unless true
        else
          1 + 1
        end
      )
    end

    it "is valid with a multi-expression body" do
      assert_valid %q(
        unless true
        else
          a = 1
          b = 1
          a + b
        end
      )
    end

    it "allows a single expression immediately following the `else`" do
      assert_valid %q(
        unless false
        else wrong end
      )
    end

    it "is invalid with a succeeding conditional block" do
      assert_invalid %q(
        unless false
        else
        elif wrong
        end
      )
    end
  end
end
