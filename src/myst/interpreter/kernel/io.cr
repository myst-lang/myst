require "../value"

module Myst::Kernel
  module IO
    include NativeAPI
    # write(fd, data)
    #
    # Write the given value (as-is) to the given file descriptor. No conversions
    # will be done on the data; the bytes passed in are written directly to the
    # file descriptor.
    #
    # Until a binary data type is defined, this method will only allow strings
    # as input.
    native_func :write, 2 do
      _fd = args.shift
      _data = args.shift

      if _fd.is_a?(TInteger)
        fd = _fd.value
      else
        raise "write: file descriptor must be an Integer"
      end

      if _data.is_a?(TString)
        data = _data.value.to_slice
        LibC.write(fd, data.pointer(data.size).as(Void*), data.size)
      else
        raise "write: data for writing must be a String, got #{_data.type_name}."
      end

      TNil.new.as(Value)
    end
  end

  register_native_api IO
end
