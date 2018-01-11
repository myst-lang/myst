require "readline"

module Myst
  class ReplIO < IO
    PROMPT = "myst> "
  
    def initialize(@input = "")
      @pos = 0
      @ask = true
    end
  
    def read(slice : Bytes)
      retrieve if @ask
      @ask = false
  
      count = slice.size
      count = Math.min(count, @input.to_slice.size)
      slice.copy_from(@input.to_slice.to_unsafe + @pos, count)
      @pos += count
      count
    end
  
    def write(slice : Bytes)
    end
  
    private def retrieve
      if line = Readline.readline(PROMPT, true)
        @pos = 0
        @input =  "#{line};\0"
      else
        @input
      end
    end
  
    private def ask_for_input?
      @input.size == @pos && @ask
    end
  end

  class Repl
    def self.start
      new.start
    end

    def initialize
      @interpreter = Interpreter.new
      prelude_require = Require.new(StringLiteral.new("stdlib/prelude.mt")).at(Location.new(__DIR__))
      @interpreter.run(prelude_require)
    end

    def start
      loop do
        program = Parser.new(ReplIO.new, "").parse
        @interpreter.run(program)
        STDOUT.puts stack_value(@interpreter.stack.pop)
      rescue ex
        STDOUT.puts ex
      end
    end

    private def stack_value(value : Value)
      NativeLib.call_func_by_name(@interpreter, value, "to_s", [] of Value).as(TString).value
    rescue
      value.to_s
    end
  end
end