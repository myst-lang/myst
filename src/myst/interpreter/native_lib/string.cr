module Myst
  class Interpreter
    NativeLib.method :string_add, TString, other : Value do
      case other
      when TString
        TString.new(this.value + other.value)
      else
        __raise_runtime_error("invalid argument for String#+: #{__typeof(other).name}")
      end
    end

    NativeLib.method :string_multiply, TString, other : Value do
      case other
      when TInteger
        # String multiplication repeats `this` `arg` times.
        TString.new(this.value * other.value)
      else
        __raise_runtime_error("invalid argument for String#*: #{__typeof(other).name}")
      end
    end

    NativeLib.method :string_to_s, TString do
      this.as(TString)
    end

    NativeLib.method :string_eq, TString, other : Value do
      case other
      when TString
        TBoolean.new(this.value == other.value)
      else
        TBoolean.new(false)
      end
    end

    NativeLib.method :string_not_eq, TString, other : Value do
      case other
      when TString
        TBoolean.new(this.value != other.value)
      else
        TBoolean.new(true)
      end
    end

    NativeLib.method :string_split, TString do
      delimiter =
        case delim_arg = __args[0]?
        when nil
          " "
        when TString
          delim_arg.value
        end

      TList.new(this.value.split(delimiter).map{ |s| TString.new(s).as(Value) })
    end

    NativeLib.method :string_size, TString do
      TInteger.new(this.value.size.to_i64)
    end

    NativeLib.method :string_chars, TString do
      TList.new(this.value.chars.map { |c| TString.new(c.to_s).as Value })
    end

    NativeLib.method :string_downcase, TString do
      TString.new(this.value.downcase)
    end

    NativeLib.method :string_upcase, TString do
      TString.new(this.value.upcase)
    end

    NativeLib.method :string_chomp, TString, other : TString? do
      other && return TString.new(this.value.chomp(other.value))
      TString.new(this.value.chomp)
    end

    NativeLib.method :string_strip, TString do
      TString.new(this.value.strip)
    end

    NativeLib.method :string_rstrip, TString do
      TString.new(this.value.rstrip)
    end

    NativeLib.method :string_lstrip, TString do
      TString.new(this.value.lstrip)
    end

    NativeLib.method :string_includes?, TString, other : TString do
      TBoolean.new(this.value.includes?(other.value))
    end

    NativeLib.method :string_at, TString, index : TInteger, length : TInteger? do
      idx = index.value

      result =
        case length
        when TInteger
          # Explicitly check that `String#[start, count]` will not fail.
          if idx < this.value.size && length.value >= 0
            TString.new(this.value[idx, length.value])
          else
            TString.new("")
          end
        else
          # Use nil-checking to assert that `index.value` is valid.
          if char = this.value[index.value]?
            TString.new(char.to_s)
          end
        end

      result || TNil.new
    end

    NativeLib.method :string_reverse, TString do
      TString.new(this.value.reverse)
    end

    def init_string(kernel : TModule)
      string_type = TType.new("String", kernel.scope)
      string_type.instance_scope["type"] = string_type

      NativeLib.def_instance_method(string_type, :+,         :string_add)
      NativeLib.def_instance_method(string_type, :*,         :string_multiply)
      NativeLib.def_instance_method(string_type, :==,        :string_eq)
      NativeLib.def_instance_method(string_type, :!=,        :string_not_eq)
      NativeLib.def_instance_method(string_type, :[],        :string_at)
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
