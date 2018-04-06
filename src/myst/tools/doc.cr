require "json"

module Myst
  # An AST visitor for parsing doc comments from Myst source code and emitting
  # the content in a JSON structure.
  #
  # Currently only operates on the given source, does not follow `require`s or
  # other imports.
  class DocGenerator
    property io : IO
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
        doc: Doc?,
        type: DocType,
        children: DocContext
      )

      def initialize(@name : String, @doc : Doc?, @type : DocType, @children = DocContext.new)
      end
    end


    def initialize(@io : IO)
      @printer = Printer.new(io)
      @docs = DocContext.new
      @current_doc = @docs
    end

    def document(node : Node)
      visit(node)

      @io.puts @docs.to_json
    end

    # Automatically recurse through all non-special nodes
    def visit(node : Node)
      node.accept_children(self)
    end

    def visit(node : ModuleDef)
      entry = Entry.new(name: node.name, doc: node.doc?, type: DocType::MODULE)
      entry.children = child_context do
        node.accept_children(self)
      end

      @current_doc[node.name] = entry
    end

    def visit(node : TypeDef)
      entry = Entry.new(name: node.name, doc: node.doc?, type: DocType::TYPE)
      entry.children = child_context do
        node.accept_children(self)
      end

      @current_doc[node.name] = entry
    end

    def visit(node : Def)
      name = String.build{ |s| printer.print(node, s) }
      entry = Entry.new(
        name: name,
        doc: node.doc?,
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
