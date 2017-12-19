deftype Integer
  # times -> self
  #
  # Call block as many times as the value of this integer.
  def times(&block)
    i = 0
    
    while i < self
      block
      i += 1
    end

    self
  end
end
