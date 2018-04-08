module Myst
  class Interpreter
    def visit(node : DocComment)
      absolute_reference_path = resolve_doc_reference_path(node.reference)
      entry = DocEntry.new(absolute_reference_path, node.returns, node.content || "")
      @doc_table[absolute_reference_path] = entry

      # Doc nodes always return `nil` for consistency with other expressions.
      stack.push(TNil.new)
    end

    private def resolve_doc_reference_path(reference : DocReference)
      String.build do |str|
        # Entries before the given reference are static by definition, so they
        # are concatenated with the static notation, `.`.
        str << doc_stack.join('.')
        str << reference.to_s
      end.lstrip('.')
    end
  end
end
