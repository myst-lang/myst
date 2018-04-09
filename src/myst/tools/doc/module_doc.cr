module Myst
  module Doc
    class ModuleDoc
      property kind = Kind::MODULE
      property name : String
      property full_name : String
      property doc : String? = nil
      property constants = {} of String => ConstDoc
      property methods = {} of String => MethodDoc
      property submodules = {} of String => ModuleDoc
      property subtypes = {} of String => TypeDoc

      JSON.mapping(
        kind: Kind,
        name: String,
        full_name: String,
        doc: {type: String?, emit_null: true},
        constants: Hash(String, ConstDoc),
        methods: Hash(String, MethodDoc),
        submodules: Hash(String, ModuleDoc),
        subtypes: Hash(String, TypeDoc)
      )


      def initialize(@name : String, @full_name : String, @doc : String?)
      end
    end
  end
end
