module Myst
  module Doc
    class TypeDoc
      property kind = Kind::TYPE
      property name : String
      property full_name : String
      property doc : String? = nil
      property constants = {} of String => ConstDoc
      property instance_methods = {} of String => MethodDoc
      property static_methods = {} of String => MethodDoc
      property initializers = {} of String => MethodDoc
      property submodules = {} of String => ModuleDoc
      property subtypes = {} of String => TypeDoc

      JSON.mapping(
        kind: Kind,
        name: String,
        full_name: String,
        doc: {type: String?, emit_null: true},
        constants: Hash(String, ConstDoc),
        instance_methods: Hash(String, MethodDoc),
        static_methods: Hash(String, MethodDoc),
        initializers: Hash(String, MethodDoc),
        submodules: Hash(String, ModuleDoc),
        subtypes: Hash(String, TypeDoc)
      )


      def initialize(@name : String, @full_name : String, @doc : String?)
      end
    end
  end
end
