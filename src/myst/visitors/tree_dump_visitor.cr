require "../visitor"
require "colorize"

module Myst
  class TreeDumpVisitor < Visitor
    visit AST::Node do
      io.puts(node.type_name)
      io << "\n"
    end

    visit AST::Block, AST::ExpressionList, AST::ParameterList do
      io << "#{node.type_name}".colorize(:red).mode(:bold)
      io << "/#{node.children.size}\n"
      recurse node.children
    end

    visit AST::FunctionDefinition do
      io << "#{node.type_name}"
      io << "|#{node.name}\n"
      recurse node.children
    end

    visit AST::FunctionParameter do
      io << "#{node.type_name}".colorize(:cyan)
      io << "|#{node.name}\n"
    end

    visit AST::SimpleAssignment do
      io << "#{node.type_name}\n".colorize(:green)
      recurse [node.target, node.value]
    end

    visit AST::IfExpression, AST::UnlessExpression, AST::ElifExpression do
      io << "#{node.type_name}\n".colorize(:blue)
      recurse [node.condition, node.body, node.alternative].compact
    end

    visit AST::ElseExpression do
      io << "#{node.type_name}\n".colorize(:blue)
      recurse [node.body]
    end

    visit AST::WhileExpression, AST::UntilExpression do
      io << "#{node.type_name}\n".colorize(:blue)
      recurse [node.condition, node.body]
    end

    visit AST::LogicalExpression, AST::EqualityExpression, AST::RelationalExpression, AST::BinaryExpression do
      io << "#{node.type_name}".colorize(:cyan)
      io << "|#{node.operator}\n"
      recurse [node.left, node.right]
    end

    visit AST::UnaryExpression do
      io << "#{node.type_name}".colorize(:cyan)
      io << "|#{node.operator}\n"
      recurse [node.operand]
    end

    visit AST::FunctionCall do
      io << "#{node.type_name}\n".colorize(:white)
      recurse node.children
    end

    visit AST::AccessExpression do
      io << "#{node.type_name}\n".colorize(:white)
      recurse [node.target, node.key]
    end

    visit AST::AccessSetExpression do
      io << "#{node.type_name}\n".colorize(:white)
      recurse [node.target, node.key, node.value]
    end


    visit AST::VariableReference do
      io << "#{node.type_name}".colorize(:dark_gray)
      io << "(#{node.name})\n"
    end

    visit AST::IntegerLiteral, AST::FloatLiteral, AST::StringLiteral, AST::SymbolLiteral, AST::BooleanLiteral do
      io << "#{node.type_name}".colorize(:yellow)
      io << "(#{node.value})\n"
    end

    visit AST::ListLiteral do
      io << "#{node.type_name}\n".colorize(:yellow)
      recurse [node.elements]
    end



    COLORS = [
      # :green, :blue, :magenta, :cyan,
      :light_green, :light_blue, :light_magenta, :light_cyan,
      :light_gray, :dark_gray
    ]

    macro recurse(children)
      current_color = COLORS.sample
      {{children}}.each_with_index do |child, child_index|
        str = String.build{ |str| child.accept(self, str) }

        str.lines.each_with_index do |line, line_index|
          if line_index == 0
            if node.children.size > 1 && child_index < node.children.size-1
              io << "├─".colorize(current_color)
            else
              io << "└─".colorize(current_color)
            end
          else
            if node.children.size > 1 && child_index < node.children.size-1
              io << "│ ".colorize(current_color)
            else
              io << "  ".colorize(current_color)
            end
          end

          io << line
          io << "\n"
        end
      end
    end
  end
end
