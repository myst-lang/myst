deftype IO
  # print(*values)
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

  # puts(*values)
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
end
