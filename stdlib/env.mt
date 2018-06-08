defmodule ENV
  include Enumerable

  def each(&block)
    keys.each do |key|
      block(key, self[key])
    end
  end

  def to_map
    map = {}
    each do |k,v|
      map[k] = v
    end
    map
  end

  def set(new_env : Map)
    clear
    new_env.each do |k,v|
      self[k] = v
    end
  end
end
