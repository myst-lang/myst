module Myst
  class TNil < Primitive(Nil)
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
