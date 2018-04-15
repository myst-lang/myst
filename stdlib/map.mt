deftype Map
  #doc empty? -> bool
  #| Return `true` if the Map contains 0 entries. Return `false` otherwise.
  def empty?
    size == 0
  end
end
