require "./spec_helper.cr"

# Check that parsing and running the given source succeeds. If given,
# additionally check that the result of running the source matches the given
# value(s).
macro it_interprets(source, *expected_stack)
  it %q(interprets {{source}}) do
    interpreter = interpret({{source}})
    {% unless expected_stack.empty? %}
      if interpreter.stack.size != {{expected_stack}}.size
        raise "Stack size does not match expected (#{interpreter.stack.size} vs. #{ {{expected_stack}}.size})"
      end

      interpreter.stack.zip({{expected_stack}}).each do |stack, expected|
        stack.should eq(expected)
      end
    {% end %}
  end
end

describe "Literals" do
  it_interprets %q(nil),    TNil.new
  it_interprets %q(false),  TBoolean.new(false)
  it_interprets %q(true),   TBoolean.new(true)
  it_interprets %q(1),      TInteger.new(1_i64)
  it_interprets %q(1.0),    TFloat.new(1.0_f64)
  it_interprets %q("hi"),   TString.new("hi")
  it_interprets %q(:hi),    TSymbol.new("hi")
end
