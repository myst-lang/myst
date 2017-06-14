module Myst
  class Scope
    property data   : Hash(String, Value)
    property parent : Scope?
    property? restrictive : Bool

    def initialize(@parent=nil, @restrictive=false, @data=Hash(String, Value).new); end

    def [](name : String)
      @data[name]
    end

    def []?(name : String)
      @data[name]?
    end

    def []=(name : String, value : Value)
      @data[name] = value
    end
  end
end
