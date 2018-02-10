deftype IO
  # print(*values) -> IO
  #
  # Writes the given values through this IO, in order. Each value will be
  # converted to a string by calling `to_s` on it, then written to the IO
  # using `write`.
  #
  # Unlike `print`, each value will also be succeeded by a newline character.
  def print(*values)
    values.each do |val|
      write("<(val.to_s)>")
    end
  end

  # puts(*values) -> IO
  #
  # Writes the given values through this IO, in order. Each value will be
  # converted to a string by calling `to_s` on it, then written to the IO
  # using `write`.
  #
  # Unlike `print`, each value will also be succeeded by a newline character.
  def puts(*values)
    values.each do |val|
      write("<(val.to_s)>\n")
    end
  end

  # gets -> String
  #
  # Reads from the IO until a newline character is found. Returns a String
  # containing all of the characters read from the IO, excluding the newline
  # character.
  def gets
    buffer = ""
    last_char = ""
    while last_char != "\n"
      buffer += last_char
      last_char = read(1)
    end
    buffer
  end
end
