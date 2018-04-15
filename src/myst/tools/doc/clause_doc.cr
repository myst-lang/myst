module Myst
  module Doc
    struct ClauseDoc
      property head : String
      property arity : Int32
      property parameters : Array(String)
      property splat_index : Int32?
      property block_parameter : String?
      property doc : String? = nil

      JSON.mapping(
        head: String,
        arity: Int32,
        parameters: Array(String),
        splat_index: {type: Int32?, emit_null: true},
        block_parameter: {type: String?, emit_null: true},
        doc: {type: String?, emit_null: true}
      )

      def initialize(@head : String, @arity : Int32, @parameters : Array(String), @splat_index : Int32?, @block_parameter : String?, @doc : String?)
      end
    end
  end
end
