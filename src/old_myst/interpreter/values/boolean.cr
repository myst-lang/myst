require "../value.cr"

module Myst
  class TBoolean < Primitive(Bool)
    def self.type_name; "Boolean"; end
    def type_name; self.class.type_name; end

    def ==(other : Value)
      self.value == other.truthy?
    end

    def !=(other : Value)
      !(self == other)
    end

    def truthy?
      self.value
    end

    def hash
      # Taken from Java. Numbers are arbitrary primes.
      self.value ? 1231 : 1237
    end
  end
end
