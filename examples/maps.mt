map = {
  a: 1,
  bc: 10,
  "string symbol": 4/2
}

map["hello"] = 5

puts(map[:a] + map[:"string symbol"])
puts(map)
