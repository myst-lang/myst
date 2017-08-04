module IO
  STDIN  = 0
  STDOUT = 1
  STDERR = 2

  def puts(arg)
    _mt_write(STDOUT, arg.to_s())
    _mt_write(STDOUT, "\n")
  end
end

IO.puts("Hello")
IO.puts(1 + 2)
