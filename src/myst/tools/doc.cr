require "json"

require "./doc/*"

module Myst
  module Doc
    alias DocContext = ModuleDoc | TypeDoc | RootDoc

    # An AST visitor for parsing doc comments from Myst source code and emitting
    # the content in a JSON structure.
    #
    # Currently only operates on the given source, does not follow `require`s or
    # other imports.
    class Generator
      # Automatically scan everything in the current directory to find Myst files
      # that can be documented.
      def self.auto_document(directory, doc_yml)
        generator = self.new(doc_yml)
        Dir[directory, directory+"/**", directory+"/**/*"].uniq.each do |entry|
          # Only consider files that end with the `.mt` extension
          if entry.ends_with?(".mt")
            file_ast = Parser.for_file(entry).parse
            generator.document(file_ast)
          end
        end

        puts generator.json
      end


      @current_context : DocContext

      def initialize(doc_yml : String)
        @docs =
          if File.exists?(doc_yml)
            RootDoc.from_yaml(File.read(doc_yml))
          else
            RootDoc.new
          end

        @current_context = @docs
      end

      def json
        @docs.to_json
      end


      def document(node : Node)
        visit(node)
      end


      # Automatically recurse through all non-special nodes
      def visit(node : Node, doc : String?=nil)
        node.accept_children(self)
      end

      def visit(node : DocComment)
        visit(node.target, node.content)
      end

      def visit(node : ModuleDef, doc : String?=nil)
        @current_context.submodules[node.name] ||= ModuleDoc.new(node.name, make_full_path(node.name), doc)
        module_doc = @current_context.submodules[node.name]
        with_context(module_doc) do
          node.accept_children(self)
        end
      end

      def visit(node : TypeDef, doc : String?=nil)
        @current_context.subtypes[node.name] ||= TypeDoc.new(node.name, make_full_path(node.name), doc)
        type_doc = @current_context.subtypes[node.name]

        with_context(type_doc) do
          node.accept_children(self)
        end
      end

      def visit(node : Def, doc : String?=nil)
        container =
          case context = @current_context
          when ModuleDoc, RootDoc
            context.methods
          when TypeDoc
            case
            when node.static?
              context.static_methods
            when node.name == "initialize"
              context.initializers
            else
              context.instance_methods
            end
          else
            # This should never be reached, since the case covers all types in
            # the union of `DocContext`.
            raise "Unhandled DocContext type #{typeof(context)}."
          end

        # Make sure that a method entry for this clause exists.
        container[node.name] ||= MethodDoc.new(node.name, make_full_path(node.name), nil)
        method_doc = container[node.name]

        clause_doc = ClauseDoc.new(
          head: Printer.print(node),
          arity: node.params.size,
          parameters: node.params.map{ |p| Printer.print(p) },
          splat_index: node.splat_index?,
          block_parameter: node.block_param?.try(&.name),
          doc: doc
        )
        method_doc.clauses << clause_doc
      end

      # Only constants that are assigned with SimpleAssigns are documentable.
      # The entire SimpleAssign is visited so that the value being assigned can
      # also be captured and added to the documentation.
      def visit(node : SimpleAssign, doc : String?=nil)
        target = node.target
        # If the target isn't a Const, it can just be ignored
        return unless target.is_a?(Const)

        const_doc = ConstDoc.new(
          target.name,
          make_full_path(target.name),
          Printer.print(node.value),
          doc
        )
        @current_context.constants[target.name] = const_doc
      end


      private def with_context(context : DocContext)
        parent_context = @current_context
        @current_context = context
        yield
        @current_context = parent_context
        context
      end

      private def make_full_path(basename : String) : String
        case context = @current_context
        when RootDoc
          basename
        else
          context.full_name + "." + basename
        end
      end
    end
  end
end
