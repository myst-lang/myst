require "../../ast"

module Myst
  class TFunctor < Value
    property name       : String
    property parameters : AST::ParameterList
    property arity      : Int32
    property body       : AST::Block
    property parent     : Scope

    def self.type_name; "Functor"; end
    def type_name; self.class.type_name; end

    def initialize(definition : AST::FunctionDefinition, @parent : Scope)
      @name       = definition.name
      @parameters = definition.parameters
      @arity      = @parameters.children.size
      @body       = definition.body
    end

    # This method allows functors to act as if they are `AST::Node`s.
    def accept(visitor)
      @body.accept(visitor)
    end


    def ==(other : TFunctor)
      false
    end

    def !=(other : TFunctor)
      true
    end

    def hash
      name.hash + arity
    end
  end
end
