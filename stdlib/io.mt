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
