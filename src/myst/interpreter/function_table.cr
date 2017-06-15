require "./functor.cr"

module Myst
  class FunctionTable
    property functions : Hash(String, Array(Functor))

    def initialize
      @functions = {} of String => Array(Functor)
    end

    # Add a function definition to the list of definitions for the
    # given name.
    def define(name : String, function : Functor)
      @functions[name] ||= [] of Functor
      @functions[name] << function
    end

    # Get the list of possible definitions for a function name.
    def []?(name)
      @functions[name]?
    end

    def [](name) : Array(Functor)
      self[name]? || raise "No function for #{name}."
    end
  end
end
