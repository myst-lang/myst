module Myst
  module Doc
    enum Kind
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
