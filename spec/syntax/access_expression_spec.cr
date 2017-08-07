require "../spec_helper"

describe "Access Expression" do
  describe "#[]" do
    it "can follow any primary or postfix expression" do
      assert_valid %q(list[1])
      assert_valid %q(list[1][2])
      assert_valid %q(make_list()[1])
      assert_valid %q(object.list[1])
      assert_valid %q(([1] + [2, 3])[2])
    end

    it "allows spaces around bracing characters" do
      assert_valid %q(
        list  [ spaced ]
      )
    end

    it "is invalid with multiple parameters" do
      assert_invalid %q(
        list[1, 2]
      )
    end

    it "is valid with any expression as a parameter" do
      ["a", "1 + 2", "b*3", "another_list[1][2]"].each do |expr|
        assert_valid %Q(
          list[#{expr}]
        )
      end
    end

    it "can span multiple lines" do
      assert_valid %q(
        list[
          idx
        ]
      )
    end
  end

  describe "#[]=" do
    it "can follow any primary or postfix expression" do
      assert_valid %q(list[1] = 1)
      assert_valid %q(list[1][2] = 2)
      assert_valid %q(make_list()[1] = 3)
      assert_valid %q(object.list[1] = 4)
      assert_valid %q(([1] + [2, 3])[2] = 5)
    end

    it "allows spaces around bracing characters" do
      assert_valid %q(
        list  [ spaced ] = 3
      )
    end

    it "is invalid with multiple index parameters" do
      assert_invalid %q(
        list[1, 2] = 3
      )
    end

    it "is valid with any expression as an index parameter" do
      ["a", "1 + 2", "b*3", "another_list[1][2]"].each do |expr|
        assert_valid %Q(
          list[#{expr}] = 2
        )
      end
    end

    it "can span multiple lines" do
      assert_valid %q(
        list[
          idx
        ] = 1 + 1
      )
    end
  end

  describe "#." do
    it "is valid when followed by an identifier" do
      assert_valid %q(
        object.property
      )
    end

    it "allows spaces around the point" do
      assert_valid %q(
        object   .   property
      )
    end

    it "is invalid when followed by non-identifiers" do
      ["1", "(a + b)", "+", "def"].each do |member|
        assert_invalid %Q(
          object.#{member}
        )
      end
    end

    it "can follow any primary or postfix expression" do
      assert_valid %q(list[1] = 1)
      assert_valid %q(list[1][2] = 2)
      assert_valid %q(make_list()[1] = 3)
      assert_valid %q(object.list[1] = 4)
      assert_valid %q(([1] + [2, 3])[2] = 5)
    end
  end
end
