module Myst
  module VM
    module Instruction
      class Base
        property type_name : String?

        def initialize(io : IO)
        end

        @[AlwaysInline]
        def arguments
          vars = {{ @type.instance_vars }}
          vars.select{ |arg| arg.is_a?(ValueLiteral) }
        end

        def display_name : String
          @type_name ||= {{@type.name}}.name.split("::").last.underscore
        end
      end
    end
  end
end
