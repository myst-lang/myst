module Myst
  class Doc
    property content : String

    def initialize(@content : String)
    end

    def_equals_and_hash content

    def to_json(json : JSON::Builder)
      json.scalar(content)
    end
  end
end
