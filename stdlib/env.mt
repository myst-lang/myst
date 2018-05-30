defmodule ENV
  include Enumerable

  def each(&block)
    keys.each do |key|
      block(key, self[key])
    end
  end
end
