require "readline"

module Myst
  class Repl

    def self.start
      new.start
    end

    def initialize
      @history = IO::Memory.new
      @interpreter = Interpreter.new
    end

    def process(level, prompt, prev_input = "")
      loop do
        if input = wait_for_input(prompt)
          new_input = "#{prev_input}\n#{input}"
          parser = Parser.new(IO::Memory.new(new_input), "")

          begin
            program = parser.parse
            @interpreter.run(program)

            STDOUT.print "=> "
            STDOUT.flush
            STDOUT.puts stack_value(@interpreter.stack.pop)
            return unless level == 0                          
          rescue ex 
            if ex.message.to_s.includes?("EOF")
              process(level + 1, "myst-r *> ", new_input)
            else
              STDOUT.puts ex.message
            end
            return unless level == 0                          
          end
        end
      end
    end

    def start
      process(0, "myst-r > ")
    end

    private def wait_for_input(prompt)
      Readline.readline(prompt, true)
    end

    private def stack_value(primitive : TPrimitive)
      primitive.value
    end

    private def stack_value(container : ContainerType)
      container.to_s
    end

    private def stack_value(string : TString)
      "\"#{string.value}\""
    end
    
    private def stack_value(list : TList)
      list.elements.map do |element|
        if element.responds_to?(:value)
          element.value
        else
          element.to_s
        end
      end
    end

    private def stack_value(value : Value)
      value.to_s
    end
  end
end