module Myst
  class Printer
    def self.print(node, io : IO)
      Printer.new.print(node, io)
    end

    def self.print(node)
      String.build do |str|
        print(node, str)
      end
    end

    # `replacements` is a Hash containing mappings from Node instances
    # to other Nodes that should be used in their place when recursing through
    # a program tree. This is useful for performing code rewrites
    # programmatically without having to modify the original program.
    property replacements : Hash(UInt64, Node)


    def initialize
      @replacements = {} of UInt64 => Node
    end

    def replace(node : Node, new_node : Node)
      replacements[node.object_id] = new_node
    end

    def print(node, io : IO)
      visit(node, io)
    end

    def print(node)
      String.build{ |str| print(node, str) }
    end


    macro make_visitor(node_type)
      def visit(node : {{node_type}}, io : IO)
        if replacement = replacements[node.object_id]?
          visit(replacement, io)
          return
        end

        {{ yield }}
      end
    end


    make_visitor Nop do
      # Nothing
    end

    make_visitor Expressions do
      expr_strs = node.children.map do |n|
        String.build{ |str| visit(n, str) }
      end
      io << expr_strs.join("\n")
    end

    make_visitor NilLiteral do
      io << "nil"
    end

    make_visitor BooleanLiteral do
      io << node.value
    end

    make_visitor IntegerLiteral do
      io << node.value
    end

    make_visitor FloatLiteral do
      io << node.value
    end

    make_visitor StringLiteral do
      io << "\"#{node.value}\""
    end

    make_visitor SymbolLiteral do
      io << ":#{node.value}"
    end

    make_visitor ListLiteral do
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

    make_visitor MapLiteral do
      io << "{"
      entry_strs =
        node.entries.map do |e|
          String.build do |str|
            k = e.key
            if k.is_a?(SymbolLiteral)
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


    make_visitor Var do
      io << node.name
    end

    make_visitor Const do
      io << node.name
    end

    make_visitor Underscore do
      io << node.name
    end

    make_visitor IVar do
      io << node.name
    end

    make_visitor ValueInterpolation do
      io << "<"
      visit(node.value, io)
      io << ">"
    end


    make_visitor SimpleAssign do
      visit(node.target, io)
      io << " = "
      visit(node.value, io)
    end


    make_visitor Or do
      visit(node.left, io)
      io << " || "
      visit(node.right, io)
    end

    make_visitor And do
      visit(node.left, io)
      io << " && "
      visit(node.right, io)
    end


    make_visitor Splat do
      io << "*"
      visit(node.value, io)
    end

    make_visitor Not do
      io << "!"
      visit(node.value, io)
    end

    make_visitor Negation do
      io << "-"
      visit(node.value, io)
    end


    make_visitor Call do
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


    make_visitor Param do
      # Splats and blocks are special cases
      if node.splat?
        io << "*"
        io << node.name
        return
      end

      if node.block?
        io << "&"
        io << node.name
        return
      end

      if node.pattern?
        visit(node.pattern, io)
        # The match operator is only necessary if a name is also given.
        if node.name?
          io << " =: "
        end
      end

      if node.name?
        io << node.name
      end

      # A restriction can only be given if another component exists, so the
      # punctuation and spacing is guaranteed to exist.
      if node.restriction?
        io << " : "
        visit(node.restriction, io)
      end
    end


    make_visitor ModuleDef do
      io << "defmodule"
      io << " "
      io << node.name
    end

    make_visitor TypeDef do
      io << "deftype"
      io << " "
      io << node.name
    end

    make_visitor Def do
      io << (node.static? ? "defstatic" : "def")
      io << " "

      io << node.name

      if node.params.size > 0 || node.block_param?
        io << "("

        param_strs = node.params.map do |param|
          String.build{ |str| visit(param, str) }
        end

        if node.block_param?
          param_strs << String.build{ |str| visit(node.block_param, str) }
        end

        io << param_strs.join(", ")
        io << ")"
      end
    end


    # Catch all for unimplemented nodes
    make_visitor Node do
      STDERR.puts "Attempting to print unknown node type: #{node.class.name}"
    end
  end
end
