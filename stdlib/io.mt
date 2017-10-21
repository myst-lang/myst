defmodule IO
  STDIN  = 0
  STDOUT = 1
  STDERR = 2

  def print(arg)
    write(STDOUT, arg.to_s())
  end

  def puts(arg)
    print(arg.to_s() + "\n")
  end

  # Read characters from STDIN until a newline character is found.
  def gets
    result = ""
    until (char = read(STDIN, 1)) == "\n" || char == nil
      result = result + char
    end
    result
  end
end
