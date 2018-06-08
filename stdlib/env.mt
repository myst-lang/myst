#doc ENV
#| `ENV` is a hash-like accessor for environment variables.
defmodule ENV
  include Enumerable
  
  #doc each -> self
  #| Yield each key=value pair to block
  def each(&block)
    keys.each do |key|
      block(key, self[key])
    end
    self
  end
  
  #doc to_map -> map
  #| Returns a map of the `ENV`
  def to_map
    map = {}
    each do |k,v|
      map[k] = v
    end
    map
  end
  
  #doc set -> self
  #| Replace current `ENV` with `new_env`
  def set(new_env : Map)
    self.clear
    new_env.each do |k,v|
      self[k] = v
    end
    self
  end
end
