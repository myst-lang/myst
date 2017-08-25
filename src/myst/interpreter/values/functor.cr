require "../../ast"

module Myst
  class TFunctor < Value
    struct Clause
      property parameters : Array(AST::FunctionParameter)
      property arity      : Int32
      property body       : AST::Block
      property parent     : Scope

      def initialize(@parameters, @body, @parent)
        @arity = @parameters.size
      end

      # This method allows functors to act as if they are `AST::Node`s.
      def accept(visitor)
        @body.accept(visitor)
      end
    end

    property name       : String
    property clauses    : Array(Clause)
    property parent     : Scope

    def self.type_name; "Functor"; end
    def type_name; self.class.type_name; end

    def initialize(definition : AST::FunctionDefinition, @parent : Scope)
      @name       = definition.name
      @clauses    = [] of Clause
      add_clause(definition)
    end

    def add_clause(definition : AST::FunctionDefinition)
      clauses << Clause.new(definition.parameters, definition.body, @parent)
    end


    def ==(other : TFunctor)
      false
    end

    def !=(other : TFunctor)
      true
    end

    def hash
      name.hash + clauses.hash
    end
  end
end
