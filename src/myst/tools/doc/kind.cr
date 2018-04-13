module Myst
  module Doc
    enum Kind
      ROOT
      CONSTANT
      METHOD
      MODULE
      TYPE

      def to_json(builder)
        builder.string(self)
      end
    end
  end
end
