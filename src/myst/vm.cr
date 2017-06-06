require "./vm/*"

module Myst
  module VM
    class VM
      property bytecode : BytecodeBuffer

      def initialize
        @bytecode = BytecodeBuffer.new
      end

      def load(file_name : String)
        @bytecode.append(BytecodeBuffer.from_file(file_name))
      end

      def load(new_code : BytecodeBuffer)
        @bytecode.append(new_code)
      end
    end
  end
end
