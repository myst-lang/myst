module Myst
  class Printer
    property output : IO

    def initialize(@output : IO=STDOUT)
    end

    def print(node)
      visit(node, @output)
    end


    def visit(node : Node, io : IO)
    end



    ##
    # For simplicity with searching, the ordering of nodes here should match
    # the ordering of nodes defined in `src/myst/syntax/ast.cr`. Tangential
    # visits (requiring more context than just a node) should all be appended
    # at the end of this file.


    def visit(node : Nop, io : IO)
      # Nothing
    end

    def visit(node : Expressions, io : IO)
      node.children.each do |n|
        visit(n, io)
      end
    end

    def visit(node : NilLiteral, io : IO)
      io << "nil"
    end

    def visit(node : BooleanLiteral, io : IO)
      io << node.value
    end

    def visit(node : IntegerLiteral, io : IO)
      io << node.value
    end

    def visit(node : FloatLiteral, io : IO)
      io << node.value
    end

    def visit(node : StringLiteral, io : IO)
      io << "\"#{node.value}\""
    end

    def visit(node : SymbolLiteral, io : IO)
      io << ":#{node.value}"
    end

    def visit(node : ListLiteral, io : IO)
      io << "["
      element_strs =
        node.elements.map do |e|
          s = String.build do |str|
            visit(e, str)
          end

          s
        end

      io << element_strs.join(", ")
      io << "]"
    end

    def visit(node : MapLiteral, io : IO)
      io << "{"
      entry_strs =
        node.entries.map do |e|
          String.build do |str|
            if (k = e.key).is_a?(SymbolLiteral)
              str << k.value
            else
              visit(k, str)
            end

            str << ": "
            visit(e.value, str)
          end
        end

      io << entry_strs.join(", ")
      io << "}"
    end
  end
end
