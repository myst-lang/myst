module Myst
  class Interpreter
    NativeLib.method :string_add, String, other : MTValue do
      case other
      when String
        this + other
      else
        __raise_runtime_error("invalid argument for String#+: #{__typeof(other).name}")
      end
    end

    NativeLib.method :string_multiply, String, other : MTValue do
      case other
      when Int64
        # String multiplication repeats `this` `arg` times.
        this * other
      else
        __raise_runtime_error("invalid argument for String#*: #{__typeof(other).name}")
      end
    end

    NativeLib.method :string_to_i, String, base : Int64? do
      begin
        base = 10 if base.nil?
        this.to_i64(base: base, whitespace: true, underscore: true, prefix: true, strict: true)
      rescue ex : ArgumentError
        __raise_runtime_error(ex.message.not_nil!)
      end
    end

    NativeLib.method :string_to_f, String, base : Int64? do
      begin
        this.to_f64(whitespace: true, strict: true)
      rescue ex : ArgumentError
        __raise_runtime_error(ex.message.not_nil!)
      end
    end

    NativeLib.method :string_to_s, String do
      this
    end

    NativeLib.method :string_eq, String, other : MTValue do
      this == other
    end

    NativeLib.method :string_not_eq, String, other : MTValue do
      this != other
    end

    NativeLib.method :string_split, String do
      delimiter =
        case delim = __args[0]?
        when nil
          " "
        when String
          delim
        else
          __raise_runtime_error("Delimiter for String#split must be a String value (got #{__typeof(delim).name}")
        end

      TList.new(this.split(delimiter).map(&.as(MTValue)))
    end

    NativeLib.method :string_size, String do
      this.size.to_i64
    end

    NativeLib.method :string_chars, String do
      TList.new(this.chars.map { |c| c.to_s.as(MTValue) })
    end

    NativeLib.method :string_downcase, String do
      this.downcase
    end

    NativeLib.method :string_upcase, String do
      this.upcase
    end

    NativeLib.method :string_chomp, String, other : String? do
      other && return this.chomp(other)
      this.chomp
    end

    NativeLib.method :string_strip, String do
      this.strip
    end

    NativeLib.method :string_rstrip, String do
      this.rstrip
    end

    NativeLib.method :string_lstrip, String do
      this.lstrip
    end

    NativeLib.method :string_includes?, String, other : String do
      this.includes?(other)
    end

    NativeLib.method :string_at, String, index : Int64, length : Int64? do
      idx = index

      result =
        case length
        when Int64
          # Explicitly check that `String#[start, count]` will not fail.
          if idx < this.size && length >= 0
            this[idx, length]
          else
            ""
          end
        else
          # Use nil-checking to assert that `index` is valid.
          if char = this[index]?
            char.to_s
          end
        end

      result || TNil.new
    end

    NativeLib.method :string_reverse, String do
      this.reverse
    end

    def init_string(kernel : TModule)
      string_type = TType.new("String", kernel.scope)
      string_type.instance_scope["type"] = string_type

      NativeLib.def_instance_method(string_type, :+,         :string_add)
      NativeLib.def_instance_method(string_type, :*,         :string_multiply)
      NativeLib.def_instance_method(string_type, :==,        :string_eq)
      NativeLib.def_instance_method(string_type, :!=,        :string_not_eq)
      NativeLib.def_instance_method(string_type, :[],        :string_at)
      NativeLib.def_instance_method(string_type, :to_i,      :string_to_i)
      NativeLib.def_instance_method(string_type, :to_f,      :string_to_f)
      NativeLib.def_instance_method(string_type, :to_s,      :string_to_s)
      NativeLib.def_instance_method(string_type, :size,      :string_size)
      NativeLib.def_instance_method(string_type, :split,     :string_split)
      NativeLib.def_instance_method(string_type, :chars,     :string_chars)
      NativeLib.def_instance_method(string_type, :chomp,     :string_chomp)
      NativeLib.def_instance_method(string_type, :strip,     :string_strip)
      NativeLib.def_instance_method(string_type, :rstrip,    :string_rstrip)
      NativeLib.def_instance_method(string_type, :lstrip,    :string_lstrip)
      NativeLib.def_instance_method(string_type, :upcase,    :string_upcase)
      NativeLib.def_instance_method(string_type, :reverse,   :string_reverse)
      NativeLib.def_instance_method(string_type, :downcase,  :string_downcase)
      NativeLib.def_instance_method(string_type, :includes?, :string_includes?)

      string_type
    end
  end
end
