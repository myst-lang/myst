module Myst
  class ASTViewer
    property io : IO

    include AST


    def initialize(@io : IO); end


    def visit(node : Node)
      io << "#{node.class_desc}\n"
      node.accept_children(self)
    end

    def visit(node : NilLiteral)
      io << "#{node.class_desc}|nil\n"
    end

    def visit(node : IntegerLiteral)
      io << "#{node.class_desc}|#{node.value}\n"
    end

    def visit(node : FloatLiteral)
      io << "#{node.class_desc}|#{node.value}\n"
    end

    def visit(node : BooleanLiteral)
      io << "#{node.class_desc}|#{node.value}\n"
    end

    def visit(node : StringLiteral)
      io << "#{node.class_desc}|#{node.value}\n"
    end

    def visit(node : SymbolLiteral)
      io << "#{node.class_desc}|#{node.value}\n"
    end

    def visit(node : ListLiteral)
      io << "#{node.class_desc}|#{node.elements.size}\n"
      node.accept_children(self)
    end



    COLORS = [
      # :green, :blue, :magenta, :cyan,
      :light_green, :light_blue, :light_magenta, :light_cyan,
      :light_gray, :dark_gray
    ]
  end
end
