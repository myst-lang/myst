module Myst
  abstract class Visitor
    macro visit(*node_types)
      {% for node_type in node_types %}
        def visit(node : {{node_type}}, io : IO)
          {{yield}}
        end
      {% end %}
    end
  end
end
