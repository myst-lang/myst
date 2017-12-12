defmodule Enumerable
  # map(&block) -> list
  #
  # Call `block` for each element of `self` and collect the result for each
  # call into a new List. If `each` does not yield any elements, the result
  # will be an empty List.
  def map(&block)
    result = []
    each do |elem|
      result = result + [block(elem)]
    end
    result
  end

  # join(delimiter) -> str
  #
  # Creates a new string from the result of calling `to_s` on every element of
  # `self`, inserting `delimiter` between each element.
  def join(delimiter : String)
    str = ""
    first = true
    each do |e|
      when first
        str = str + e.to_s
        first = false
      else
        str = str + delimiter + e.to_s
      end
    end
    str
  end

  # size -> integer
  #
  # Returns the size of the enumerable, as determined by the number of elements
  # yielded by `each`.
  def size
    counter = 0

    each do |e|
      counter += 1
    end

    counter
  end

  # all?(&block) -> boolean
  #
  # Return true if all elements in the enumerable cause `block` to return a
  # truthy value.
  def all?(&block)
    result = nil
    each do |e|
      when block(e)
        result = true
      else
        break result = false
      end
    end
    result
  end

  # any?(&block) -> boolean
  #
  # Return true if at least one element in the enumerable evaluates to a
  # truthy value for the given block.
  def any?(&block)
    result = nil
    each do |e|
      when block(e)
        break result = true
      else
        result = false
      end
    end
    result
  end

  # find(&block) -> element
  #
  # Iterate the enumerable, passing each element to `block`. Return the first
  # element for which the block returns a truthy value.
  def find(&block)
    result = nil
    each do |e|
      when block(e)
        result = e
        break
      end
    end
    result
  end

  # min -> element
  #
  # Returns the element with the lowest value as determined by <
  def min
    value = nil
    
    each do |e|
      when value == nil || e < value
        value = e
      end
    end

    value
  end

  # max -> element
  #
  # Returns the element with the highest value as determined by >
  def max
    value = nil
    
    each do |e|
      when value == nil || e > value
        value = e
      end
    end

    value
  end

  # sort -> list
  #
  # Returns a sorted list of all elements
  def sort
    list = map { |e| e }
    when size < 2
      return list
    end

    # insertion sort
    i = 1
    while i < size
      value = list[i]
      j = i - 1

      while j >= 0 && list[j] > value
        list[j + 1] = list[j]
        j -= 1
      end

      list[j + 1] = value
      i += 1
    end

    list
  end
end
