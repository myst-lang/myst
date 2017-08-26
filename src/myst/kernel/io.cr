require "../value"

module Myst::Kernel
  module IO
    extend self
    include NativeAPI

    # A pool of currently-open file descriptors to avoid creating multiple
    # handles on a single file.
    @@file_pool = {} of Int32 => ::IO::FileDescriptor

    private def find_or_create_handle(descriptor)
      if existing = @@file_pool[descriptor]?
        existing
      else
        @@file_pool[descriptor] = ::IO::FileDescriptor.new(descriptor)
      end
    end

    # write(fd, data)
    #
    # Write the given value (as-is) to the given file descriptor. No conversions
    # will be done on the data; the bytes passed in are written directly to the
    # file descriptor.
    #
    # Until a binary data type is defined, this method will only allow strings
    # as input.
    def write(args, block, interpreter)
      _fd = args.shift
      _data = args.shift

      if _fd.is_a?(TInteger)
        fd = find_or_create_handle(_fd.value.to_i32)
      else
        raise "write: file descriptor must be an Integer"
      end

      if _data.is_a?(TString)
        fd.write(_data.value.to_slice)
        fd.flush
      else
        raise "write: data for writing must be a String, got #{_data.type_name}."
      end

      TNil.new.as(Value)
    end

    native_func :write, 2, IO.write

    # read(fd, length)
    #
    # Read `length` bytes from the given file descriptor. The result will be
    # a String containing those bytes.
    def read(args, block, interpreter)
      _fd = args.shift
      _length = args.shift

      if _fd.is_a?(TInteger)
        fd = find_or_create_handle(_fd.value.to_i32)
      else
        raise "read: file descriptor must be an Integer"
      end

      if _length.is_a?(TInteger)
        length = _length.value
      else
        raise "read: length to read must be an Integer"
      end

      string = fd.read_string(length)
      TString.new(string).as(Value)
    end

    native_func :read, 2, IO.read
  end

  register_native_api IO
end
