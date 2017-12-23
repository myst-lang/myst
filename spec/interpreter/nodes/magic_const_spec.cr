require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - MagicConstant" do
  it_interprets %q(__LINE__), [val(1)]
  it_interprets %q(
    def foo
      __LINE__
    end

    foo
  ), [val(3)]
  
  it_interprets %q(__FILE__), [val(File.join(Dir.current,"test_source.mt"))]
  it_interprets %q(__DIR__),  [val(File.join(Dir.current))]
end
