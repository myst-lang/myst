require "./value.cr"

module Myst
  class Scope < Value
    property data   : Hash(String, Value)
    property parent : Scope?

    def type_name; "Scope"; end

    def initialize(@parent=nil, @data=Hash(String, Value).new); end

    def []?(name : String)
      data[name]? || (p = parent) && p[name]?
    end

    def [](name : String)
      self[name]? || raise IndexError.new
    end

    def []=(name : String, value : Value)
      if self[name]?
        assign_existing(name, value)
      else
        data[name] = value
      end
    end

    def assign(name : String, value : Value, make_new=false)
      if make_new
        data[name] = value
      else
        self[name] = value
      end
    end

    def full_clone
      new_scope = Scope.new(parent)
      data.each do |key, value|
        new_scope[key] = value
      end
      new_scope
    end

    # Insert `scope` at the front of the "ancestor chain" for this scope.
    def insert_parent(scope : Scope)
      scope.parent = self.parent
      self.parent = scope
    end


    def hash
      data.keys.sum(&.hash)
    end


    def inspect
      String.build do |str|
        str << "{"
        str << data.map{ |key, value| "#{key}: #{value.type_name}"}.join(", ")
        str << "}"
      end
    end


    protected def assign_existing(name : String, value : Value)
      if data[name]?
        data[name] = value
      elsif p = parent
        p.assign_existing(name, value)
      end

      value
    end
  end
end
