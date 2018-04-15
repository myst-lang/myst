defmodule Enumerable
  #doc map(&block) -> list
  #| Call `block` for each element of `self` and collect the result for each
  #| call into a new List. If `each` does not yield any elements, the result
  #| will be an empty List.
  def map(&block)
    result = []
    each do |elem|
      result.push(block(elem))
    end
    result
  end

  #doc join(delimiter) -> str
  #| Creates a new string from the result of calling `to_s` on every element of
  #| `self`, inserting `delimiter` between each element.
  def join(delimiter : String)
    str = ""
    first = true
    each do |e|
      when first
        str += e.to_s
        first = false
      else
        str += "<(delimiter)><(e)>"
      end
    end
    str
  end

  #doc size -> integer
  #| Returns the size of the enumerable, as determined by the number of
  #| elements yielded by `each`.
  def size
    counter = 0

    each do |e|
      counter += 1
    end

    counter
  end

  #doc all?(&block) -> boolean
  #| Return true if all elements in the enumerable cause `block` to return a
  #| truthy value.
  def all?(&block)
    result = nil
    each do |e|
      when block(e)
        result = true
      else
        result = false
        break
      end
    end
    result
  end

  #doc any?(&block) -> boolean
  #| Return true if at least one element in the enumerable evaluates to a
  #| truthy value for the given block.
  def any?(&block)
    result = nil
    each do |e|
      when block(e)
        result = true
        break
      else
        result = false
      end
    end
    result
  end

  #doc find(&block) -> element
  #| Iterate the enumerable, passing each element to `block`. Return the first
  #| element for which the block returns a truthy value.
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

  #doc select(&block) -> list
  #| Iterate the enumerable, passing each element to `block`. Return all
  #| elements for which the block returns a truthy value.
  def select(&block)
    result = []

    each do |e|
      when block(e)
        result.push(e)
      end
    end

    result
  end

  #doc min -> element
  #| Returns the element with the lowest value as determined by <.
  def min
    value = nil

    each do |e|
      when value == nil || e < value
        value = e
      end
    end

    value
  end

  #doc max -> element
  #| Returns the element with the highest value as determined by >.
  def max
    value = nil

    each do |e|
      when value == nil || e > value
        value = e
      end
    end

    value
  end

  #doc sort -> list
  #| Returns a sorted list of all elements.
  def sort
    list = to_list
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

  #doc to_list -> list
  #| Returns a list containing all elements.
  def to_list
    list = []

    each do |e|
      list.push(e)
    end

    list
  end

  #doc reduce(value=nil, &block) -> element
  #| For every element in the enumerable, call block with the result of the
  #| previous call and the current element as arguments. Returns a single
  #| value.
  #|
  #| If an initial value is given, it will be used as the accumulator
  #| argument for the block call with the first element. If an initial value is
  #| not given, the first element will not be passed to the block and will be
  #| be used as the accumulator for the block call with the second element.
  def reduce(&block)
    value = nil

    each do |e|
      when value == nil
        value = e
      else
        value = block(value, e)
      end
    end

    value
  end
  def reduce(value, &block)
    each do |e|
      value = block(value, e)
    end

    value
  end
end
