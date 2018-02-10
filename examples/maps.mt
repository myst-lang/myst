var = 3

map = {
  a: 1,
  bc: var,
  "string symbol": 4/2
}

map["hello"] = 5

STDOUT.puts(map[:a] + map[:"string symbol"])

def func(a, b)
  a + b
end

# Examples of key interpolation
interpolant = {
  <1>: :integer,
  <2.4>: :float,
  <"hi">: :string,
  <[1, 2, 3]>: :list,
  <var>: :variable,
  <func(3, 4)>: :expression,
  <:what>: :no # don't do this
}

STDOUT.puts(interpolant[7])
STDOUT.puts(interpolant[:what])
STDOUT.puts(interpolant[[1,2,3]])
