require "../../ast"

module Myst
  class TFunctor < Value
    property name       : String
    property parameters : AST::ParameterList
    property arity      : Int32
    property body       : AST::Block
    property scope      : Scope

    def self.type_name; "Functor"; end
    def type_name; self.class.type_name; end

    def initialize(definition : AST::FunctionDefinition, parent_scope)
      @name       = definition.name
      @parameters = definition.parameters
      @arity      = @parameters.children.size
      @body       = definition.body
      @scope      = Scope.new(parent: parent_scope)

      @scope[definition.name] = self
    end

    # This method allows functors to act as if they are `AST::Node`s.
    def accept(visitor)
      @body.accept(visitor)
    end


    def ==(other : TFunctor) : TBoolean
      TBoolean.new(false)
    end

    def !=(other : TFunctor) : TBoolean
      TBoolean.new(true)
    end
  end
end
