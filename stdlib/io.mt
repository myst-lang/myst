deftype IO
  #doc print(value) -> IO
  #| Writes the given value through this IO, in order. The value will be
  #| converted to a string by calling `to_s` on it, then written to the IO
  #| using `write`.
  def print(value)
    write("<(value)>")
  end

  #doc puts(*values) -> IO
  #| Writes the given values through this IO, in order. Each value will be
  #| converted to a string by calling `to_s` on it, then written to the IO
  #| using `write`.
  #|
  #| Unlike `print`, each value will also be succeeded by a newline character.
  #| If no arguments are given, a single newline character will be written to
  #| the IO.
  def puts
    write("\n")
    self
  end

  def puts(*values)
    values.each do |val|
      write("<(val)>\n")
    end
  end

  #doc gets -> String
  #| Reads from the IO until a newline character is found. Returns a String
  #| containing all of the characters read from the IO, excluding the newline
  #| character.
  #|
  #| If a `read` call returns an empty String before a newline character is
  #| found, the characters up until that point will be returned.
  def gets
    buffer = ""
    last_char = ""

    while last_char != "\n"
      buffer += last_char
      last_char = read(1)

      when last_char == "" || last_char == "\0"
        # raise/rescue is a work around for the currently-broken explicit
        # returns, mentioned in https://github.com/myst-lang/myst/issues/155.
        raise buffer
      end
    end

    buffer
  rescue buffer
    buffer
  end
end
