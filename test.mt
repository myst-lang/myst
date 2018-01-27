deftype Test
  defstatic hello(&block)
    block()
  end
end

i = 0

func = fn
  ->() { 10.times{ i += 1 } }
end

Test.hello(&func)
