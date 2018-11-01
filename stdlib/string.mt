deftype String
  #doc empty? -> boolean
  #| Return `true` if the String contains 0 characters. Return `false` otherwise.
  def empty? : Boolean
    size == 0
  end

  def each_char(&block) : List
    chars.each { |char| block(char)}
  end
end
