module Myst
  class SemanticVisitor
    def visit(node : Def)
      given_names = Set(String).new

      node.params.each do |param|
        if given_names.includes?(param.name)
          fail("parameter #{param.name} listed twice")
        else
          given_names.add(param.name)
        end
      end
    end
  end
end
