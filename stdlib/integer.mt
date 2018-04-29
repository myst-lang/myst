deftype Integer
  #doc times(&block) -> self
  #| Call block as many times as the value of this integer.
  def times(&block)
    i = 0

    while i < self
      block()
      i += 1
    end

    self
  end

  #doc successor -> integer
  #| Returns the next smallest integer that is greater than this integer. This
  #| method is primarily intended for use with the `Range` type.
  def successor
    self + 1
  end

  #doc predeccesor -> integer
  #| Returns the next largest integer that is smaller than this integer. This
  #| method is primarily intended for use with the `Range` type.
  def predecessor
    self - 1
  end
end
