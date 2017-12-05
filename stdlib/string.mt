deftype String
  include Enumerable

  # empty? -> bool
  #
  # Return `true` if the String contains 0 characters. Return `false` otherwise.
  def empty?
    size == 0
  end
end
