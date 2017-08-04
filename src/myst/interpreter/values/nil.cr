module Myst
  class TNil < Primitive(Nil)
    def self.type_name; "Nil"; end
    def type_name; self.class.type_name; end

    def initialize
      super(nil)
    end

    def ==(other : TNil) : TBoolean
      TBoolean.new(true)
    end

    def !=(other : TNil) : TBoolean
      TBoolean.new(false)
    end

    def truthy?
      false
    end
  end
end
