module Myst
  module Doc
    class MethodDoc
      property kind = Kind::METHOD
      property name : String
      property full_name : String
      property separator : String
      property clauses = [] of ClauseDoc
      property doc : String? = nil

      JSON.mapping(
        kind: Kind,
        name: String,
        full_name: String,
        separator: String,
        clauses: Array(ClauseDoc),
        doc: {type: String?, emit_null: true}
      )


      def initialize(@name : String, @full_name : String, @separator : String, @doc : String?)
      end
    end
  end
end
