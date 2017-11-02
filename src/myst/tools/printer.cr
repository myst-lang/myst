module Myst
  class Printer
    property output : IO

    def initialize(@output : IO=STDOUT)
    end

    def print(node)
      visit(node, @output)
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
      expr_strs = node.children.map do |n|
        String.build{ |str| visit(n, str) }
      end
      io << expr_strs.join("\n")
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


    def visit(node : Var, io : IO)
      io << node.name
    end

    def visit(node : Const, io : IO)
      io << node.name
    end

    def visit(node : Underscore, io : IO)
      io << node.name
    end

    def visit(node : IVar, io : IO)
      io << node.name
    end


    def visit(node : SimpleAssign, io : IO)
      visit(node.target, io)
      io << " = "
      visit(node.value, io)
    end


    def visit(node : Call, io : IO)
      if node.infix?
        visit(node.receiver, io)
        io << " #{node.name} "
        # Infix calls will only have one argument and no block
        visit(node.args.first, io)
        return
      end

      # Access notation is a special case where arguments are placed between
      # the braces, rather than in separate parentheses.
      if node.name == "[]"
        visit(node.receiver, io)
        io << "["
        arg_strs = node.args.map do |arg|
          String.build do |str|
            visit(arg, str)
          end
        end

        io << arg_strs.join(", ")
        io << "]"
        return
      end

      if node.receiver?
        visit(node.receiver, io)
        io << "."
      end

      io << node.name

      if node.args.size > 0
        io << "("
        arg_strs = node.args.map do |arg|
          String.build do |str|
            visit(arg, str)
          end
        end

        io << arg_strs.join(", ")
        io << ")"
      end

      if node.block?
        # TODO: block stuff
        # With no arguments or block, a blank call is just the name
      end
    end



    # Catch all for unimplemented nodes
    def visit(node, io)
      STDERR.puts "Attempting to print unknown node type: #{node.class.name}"
    end
  end
end
