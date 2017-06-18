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

    def full_clone
      new_scope = Scope.new(parent, restrictive?)
      data.each do |key, value|
        new_scope[key] = value
      end
      new_scope
    end


    def inspect
      String.build do |str|
        str << "{"
        str << data.map{ |key, value| "#{key}: #{value.class}"}.join(", ")
        str << "}"
      end
    end
  end
end
