module Myst
  module Semantic
    class DuplicateParamNamesAssertion < Assertion
      property def_node  : Def
      property names_in_params = {} of String => Array(Node)

      def initialize(@def_node : Def); end

      def run
        def_node.params.each{ |param| visit_param(param) }

        names_in_params.each do |name, nodes|
          if nodes.size > 1
            original_str  = Myst::Printer.print(def_node)
            resolved_str  = create_resolved_str(nodes)

            fail! def_node.location.not_nil!, <<-FAIL_MESSAGE
            Parameter `#{name}` is bound more than once in this definition. Use the value
            interpolation syntax (`< >`) to use `#{name}` as a pattern to match against.

            original:   #{original_str}
            resolved:   #{resolved_str}
            FAIL_MESSAGE
          end
        end
      end

      private def create_resolved_str(nodes : Array(Node))
        printer = Myst::Printer.new
        nodes[1..-1].each do |node|
          new_node = node.dup

          case new_node
          when Param
            # If `new_node` is a Param, the name of the param has matched.
            # The replacement for this is moving the name into a
            # ValueInterpolation used as the pattern of the Param.
            new_node.pattern = ValueInterpolation.new(Var.new(new_node.name))
            new_node.name = nil
          when Var
            new_node = ValueInterpolation.new(new_node)
          end

          printer.replace(node, new_node)
        end

        printer.print(def_node)
      end

      private def visit_param(param : Param)
        if name = param.name?
          add_name(name, param)
        end

        if pattern = param.pattern?
          visit_pattern(pattern)
        end
      end


      private def visit_pattern(node : ListLiteral)
        node.elements.each{ |el| visit_pattern(el) }
      end

      private def visit_pattern(node : MapLiteral)
        # Only Map values can contain names (Map keys cannot be pattern matched
        # based on a static value).
        node.entries.each{ |el| visit_pattern(el.value) }
      end

      private def visit_pattern(node : Var)
        add_name(node.name, node)
      end

      private def visit_pattern(node : Node)
        # Only certain patterns can contain names, so this is a fallback
        # to support any pattern type without extra analysis.
      end


      private def add_name(name : String, node : Node)
        if node_list = names_in_params[name]?
          node_list.push(node)
        else
          names_in_params[name] = [node] of Node
        end
      end
    end
  end
end
