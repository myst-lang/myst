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

  # Read characters from STDIN until a newline character is found.
  def gets
    result = ""
    newline_found = false
    while !newline_found
      char = read(STDIN, 1)
      if char == "\n"
        newline_found = true
      else
        result = result + char
      end
    end
    result
  end
end
