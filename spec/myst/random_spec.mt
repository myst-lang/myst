require "stdlib/spec.mt"

describe("Random") do
  describe("#rand") do
    describe("without arguments") do
      it("returns a Float value") do
        assert(Random.rand.type.to_s == "Float")
      end

      it("returns a value in the range [0, 1]") do
        rand_result = Random.rand
        assert(0.0 <= rand_result && rand_result <= 1.0)
      end
    end

    describe("with an Integer argument") do
      it("returns an Integer value") do
        assert(Random.rand(500).type.to_s == "Integer")
      end

      it("returns a value between 0 and the given maximum") do
        rand_result = Random.rand(500)
        assert(0 <= rand_result && rand_result <= 500)
      end
    end

    describe("with a Float argument") do
      it("returns a Float value") do
        assert(Random.rand(500.0).type.to_s == "Float")
      end

      it("returns a value between 0 and the given maximum") do
        rand_result = Random.rand(500.0)
        assert(0.0 <= rand_result && rand_result <= 500.0)
      end
    end
  end
end
