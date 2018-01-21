require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - Random methods" do
  describe "#rand" do 
    it "Returns a float in the range of [0, 1] without any arguments" do
      itr = interpret_with_mocked_output %q(
        i = 0
        while i < 32            
          IO.puts(Random.rand())
          i += 1
        end
      )      

      # Put `unless line.empty?` here because `String#split("\n")` 
      # apparently returns an emptry string if a string ends with a newline
      itr.output.to_s.split("\n").each { |line| (0_f64..1_f64).should contain line.to_f64 unless line.empty? }
    end

    it "Returns an integer when a max integer is specified" do
      itr = interpret_with_mocked_output %q(
        i = 0
        while i < 32            
          IO.puts(Random.rand(500) + 500)
          i += 1
        end
      )

      itr.output.to_s.split("\n").each { |line| (500...1000).should contain line.to_i64 unless line.empty? }      
    end
    
    it "Returns something" do
      itr = interpret_with_mocked_output %q(
        IO.puts(Random.rand())
      )
      itr.output.to_s.empty?.should eq false

      itr = interpret_with_mocked_output %q(
        IO.puts(Random.rand(141245121))
      )
      itr.output.to_s.empty?.should eq false      
    end
  end
end