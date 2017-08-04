module IO
  STDIN  = 0
  STDOUT = 1
  STDERR = 2

  def print(arg)
    write(STDOUT, arg.to_s())
  end

  def puts(arg)
    print(arg.to_s() + "\n")
  end
end


IO.print("Hello, ")
IO.puts("world")
IO.puts(1 + 2)
IO.write(IO.STDERR, "oops.\n")
