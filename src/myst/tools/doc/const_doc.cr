module Myst
  module Doc
    class ConstDoc
      property kind = Kind::CONSTANT
      property name : String
      property full_name : String
      property value : String
      property doc : String? = nil

      JSON.mapping(
        kind: Kind,
        name: String,
        full_name: String,
        value: String,
        doc: {type: String?, emit_null: true}
      )


      def initialize(@name : String, @full_name : String, @value : String, @doc : String?)
      end
    end
  end
end
