module Enumerable
  def map(&block)
    result = []
    each() do |e|
      result = result + [block(e)]
    end
    result
  end
end

module List
  include Enumerable
end


l = [1, 2, 3]
r = l.map() do |e|
  e * 2
end

IO.puts(r)
