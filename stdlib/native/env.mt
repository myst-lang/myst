defmodule ENV
  #doc [] -> string?
  #| Returns value assigned to `key`. Else returns nil.
  def [](key : String)
  end

  #doc []= -> string
  #| Assigns `value` to `key`. Returns `value`.
  def []=(key : String, value : String)
  end

  #doc fetch -> string
  #| Behaves exactly like `ENV[]` when `key` is present. 
  #| Raises an exception if `key` is not present.
  def fetch(key : String)
  end

  #doc fetch -> string
  #| Behaves exactly like `ENV[]` when `key` is present. 
  #| Returns `default` if `key` is not assigned any value.
  def fetch(key : String, default)
  end

  #doc keys -> list
  #| Returns a list containing all the keys of the environment.
  def keys
  end

  #doc values -> list
  #| Returns a list containing all the values of the environment.
  def values
  end

  #doc delete -> string?
  #| Removes the key=value pair specified by `key` from the environment. 
  #| If `key` is present: the value assigned to the key (before deletion) is returned.
  #1 Otherwise nil is returned.
  def delete(key : String)
  end

  #doc clear -> nil
  #| Clears every key=value pair of the environment.
  def clear
  end

  #doc has_key? -> boolean
  #| Returns true if `ENV.keys` contains `key`, otherwise false.
  def has_key?(key : String)
  end
end
