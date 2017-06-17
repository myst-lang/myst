module Myst
  class TNativeFunctor < TObject
    def ==(other : TNativeFunctor) : TBoolean
      TBoolean.new(false)
    end

    def !=(other : TNativeFunctor) : TBoolean
      TBoolean.new(true)
    end
  end
end
