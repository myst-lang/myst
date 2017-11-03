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
end
