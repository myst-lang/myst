module Myst
  class TNil < Primitive(Nil)
    def self.type_name; "Nil"; end
    def type_name; self.class.type_name; end

    def initialize
      super(nil)
    end

    def ==(other : TNil)
      true
    end

    def !=(other : TNil)
      false
    end

    def truthy?
      false
    end

    def hash
      0
    end
  end
end
