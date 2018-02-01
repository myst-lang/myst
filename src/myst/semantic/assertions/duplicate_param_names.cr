module Myst
  module Semantic
    class ParamNamesAssertion < Assertion
      property owner  : Node
      property params : Array(Param)
      property names_in_params = {} of String => Array(Node)

      def initialize(@owner : Node, @params : Array(Param))
      end

      def message : String
        "Duplicate parameter name given"
      end

      def run
        params.each{ |param| visit_param(param) }

        names_in_params.each do |name, nodes|
          if nodes.size > 1
            raise Error.new("Parameter `#{name}` specified more than once.")
          end
        end
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
