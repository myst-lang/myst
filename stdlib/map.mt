deftype Map
  #doc empty? -> bool
  #| Return `true` if the Map contains 0 entries. Return `false` otherwise.
  def empty?
    size == 0
  end

  def keys
    list = []
    self.each do |k,_|
      list.push(k)
    end
    list
  end
  
  def values
    list = []
    self.each do |_,v|
      list.push(v)
    end
    list
  end
end
