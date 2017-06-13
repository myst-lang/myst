require "../ast"

module Myst
  class Functor
    property name       : String
    property parameters : AST::ParameterList
    property arity      : Int32
    property body       : AST::Block

    def initialize(definition : AST::FunctionDefinition)
      @name       = definition.name
      @parameters = definition.parameters
      @arity      = @parameters.children.size
      @body       = definition.body
    end
  end
end
