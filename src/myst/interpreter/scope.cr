require "./value.cr"

module Myst
  class Scope < Value
    property data   : Hash(String, Value)
    property parent : Scope?

    def type_name; "Scope"; end

    def initialize(@parent=nil, @data=Hash(String, Value).new); end

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
      new_scope = Scope.new(parent)
      data.each do |key, value|
        new_scope[key] = value
      end
      new_scope
    end


    def inspect
      String.build do |str|
        str << "{"
        str << data.map{ |key, value| "#{key}: #{value.type_name}"}.join(", ")
        str << "}"
      end
    end
  end
end
