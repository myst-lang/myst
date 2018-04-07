require "json"

module Myst
  # An AST visitor for parsing doc comments from Myst source code and emitting
  # the content in a JSON structure.
  #
  # Currently only operates on the given source, does not follow `require`s or
  # other imports.
  class DocGenerator
    property printer : Printer

    enum DocType
      # Types defined using `deftype`
      TYPE
      # Modules defined using `defmodule`
      MODULE
      # Any method defined using `def`
      METHOD
      # Any method defined using `defstatic`. Only valid within a type.
      STATIC_METHOD
    end

    alias DocContext = Hash(String, Entry)

    struct Entry
      property name : String
      property doc : Doc?
      property type : DocType
      property children : DocContext

      JSON.mapping(
        name: String,
        doc: { type: Doc?, emit_null: true },
        type: DocType,
        children: DocContext
      )

      def initialize(@name : String, @doc : Doc?, @type : DocType, @children = DocContext.new)
      end
    end


    # Automatically scan everything in the current directory to find Myst files
    # that can be documented.
    def self.auto_document(directory = Dir.current)
      generator = self.new
      Dir[directory, directory+"/*", directory+"/**/*"].each do |entry|
        # Only consider files that end with the `.mt` extension
        if entry.ends_with?(".mt")
          file_ast = Parser.for_file(entry).parse
          generator.document(file_ast)
        end
      end

      puts generator.json
    end


    def initialize
      @printer = Printer.new
      @docs = DocContext.new
      @current_doc = @docs
    end


    def document(node : Node)
      visit(node)
    end

    # Return a JSON representation of the current documentation structure.
    def json
      @docs.to_json
    end

    # Automatically recurse through all non-special nodes
    def visit(node : Node)
      node.accept_children(self)
    end

    def visit(node : ModuleDef)
      entry = Entry.new(name: node.name, doc: nil, type: DocType::MODULE)
      entry.children = child_context do
        node.accept_children(self)
      end

      @current_doc[node.name] = entry
    end

    def visit(node : TypeDef)
      entry = Entry.new(name: node.name, doc: nil, type: DocType::TYPE)
      entry.children = child_context do
        node.accept_children(self)
      end

      @current_doc[node.name] = entry
    end

    def visit(node : Def)
      name = String.build{ |s| printer.print(node, s) }
      entry = Entry.new(
        name: name,
        doc: nil,
        type: node.static? ? DocType::STATIC_METHOD : DocType::METHOD
      )

      @current_doc[name] = entry
    end


    private def child_context(&block : ->)
      parent_context = @current_doc
      child_context = DocContext.new
      @current_doc = child_context
      yield
      @current_doc = parent_context

      child_context
    end
  end
end
