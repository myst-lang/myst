module Myst
  class Interpreter
    NativeLib.passthrough(ENV.clear, return_nil: true)
    NativeLib.passthrough(ENV.has_key?(key : String))
    
    NativeLib.method(:env_get, TModule, key : String) do
      ENV[key]? || TNil.new
    end

    NativeLib.method(:env_assign, TModule, key : String, val : String) do
      ENV[key]=val
    end

    NativeLib.method(:env_fetch, TModule, key : String, default : String? = nil) do
      if default
        ENV.fetch(key, default)
      else
        ENV.fetch(key)
      end
    end

    NativeLib.method(:env_delete, TModule, key : String) do
      ENV.delete(key) || TNil.new
    end

    NativeLib.method(:env_keys, TModule) do
      TList.new(ENV.keys.map(&.as(MTValue)))
    end

    NativeLib.method(:env_values, TModule) do
      TList.new(ENV.values.map(&.as(MTValue)))
    end

    def init_env
      env_module = TModule.new("ENV", @kernel.scope)
      NativeLib.def_method(env_module, :[],  :env_get)
      NativeLib.def_method(env_module, :[]=, :env_assign)
      NativeLib.def_method(env_module, :fetch,  :env_fetch)
      NativeLib.def_method(env_module, :keys,   :env_keys)
      NativeLib.def_method(env_module, :values, :env_values)
      NativeLib.def_method(env_module, :delete,   :env_delete)
      NativeLib.def_method(env_module, :clear,    :passthrough_ENV_clear)
      NativeLib.def_method(env_module, :has_key?, :passthrough_ENV_has_key?)
      env_module
    end
  end
end
