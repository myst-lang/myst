require "stdlib/spec.mt"

initial_env = ENV.to_m

# Keys and values used for testing
SHAKE_KEY = "Shakespeare"
SHAKE     = "To be, or not to be: that is the question"
EIN_STEIN_KEY = "Einstein"
EIN_STEIN     = "two things are infinite: the universe and human stupidity"

TEST_ENV = { 
  <SHAKE_KEY>:     SHAKE, 
  <EIN_STEIN_KEY>: EIN_STEIN, 
  <"HOME">: "/Users/Bob",
  <"PWD">:  "/Users/Bob/Projects/myst-lang/myst"
}

def set_test_env
  ENV.set(TEST_ENV)
end

def random_key
  key = ""
  16.times {key += Random.rand(10).to_s}
  key
end

describe("ENV[]") do
  it("returns the value associated with a key") do
    set_test_env
    assert(ENV[SHAKE_KEY])     == SHAKE
    assert(ENV[EIN_STEIN_KEY]) == EIN_STEIN
  end

  it("returns a nil, if no value is set with the given key, otherwise always a string") do
    set_test_env
    assert(ENV[SHAKE_KEY]).is_a(String) 
    assert(ENV[EIN_STEIN_KEY]).is_a(String)
    assert(ENV[random_key]).is_a(Nil)
  end
end

describe("ENV.fetch") do
  it("is just the same as ENV[] when the key is present in the environment, if not: fetch returns provided default (which defaults to nil) instead of nil; if no default is specified, an error is raised") do
    set_test_env
    assert(ENV.fetch(random_key, "none")) == "none"
    assert(ENV.fetch(SHAKE_KEY)) == SHAKE
    assert{ENV.fetch(random_key)}.raises
  end
end

describe("ENV.has_key?") do
  it("returns true if environment has specified key") do
    set_test_env
    assert(ENV.has_key?(SHAKE_KEY)).is_true
    assert(ENV.has_key?(random_key)).is_false
  end
end

describe("ENV.delete") do
  it("deletes the key value pair of specified key") do
    set_test_env 
    ENV.delete(EIN_STEIN_KEY)
    assert(ENV[EIN_STEIN_KEY]).is_nil
  end

  it("returns the value assigned to specified key; if no value is assigned to key, nil is returned") do
    set_test_env
    assert(ENV.delete(EIN_STEIN_KEY)) == TEST_ENV[EIN_STEIN_KEY]
    assert(ENV.delete(random_key)).is_nil
  end
end

describe("ENV[]=") do
  it("sets the given value assigned to given key") do
    set_test_env
    assert(ENV[SHAKE_KEY])     == SHAKE
    assert(ENV[EIN_STEIN_KEY]) == EIN_STEIN
  end
end

describe("ENV.each") do  
  it("yields each key and value to given block") do
    set_test_env
    map = {}
    ENV.each do |k,v|
      map[k] = v
    end
    map.each do |k,_|
      assert(ENV[k]) == map[k]
      assert(map[k]) == ENV[k]
    end
  end
end

describe("ENV.keys") do
  it("returns a list of all the keys in the environment") do
    set_test_env
    assert(ENV.keys) == TEST_ENV.keys
  end
end

describe("ENV.to_m") do
  it("returns a map of the current environment") do
    set_test_env
    assert(ENV.to_m) == TEST_ENV
  end
end

describe("ENV.set") do
  it("sets the environment to given map") do
    set_test_env
    assert(ENV.to_m) == TEST_ENV
  end
end

ENV.set(initial_env)
