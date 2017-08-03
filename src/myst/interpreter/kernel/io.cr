require "../value"

module Myst::Kernel
  # _mt_write(fd, data)
  #
  # Write the given value (as-is) to the given file descriptor. No conversions
  # will be done on the data; the bytes passed in are written directly to the
  # file descriptor.
  #
  # Until a binary data type is defined, this method will only allow strings
  # as input.
  def _mt_write(arguments : Array(Value))
    if (fd_value = arguments.shift).is_a?(TInteger)
      fd = fd_value.value
    else
      raise "_mt_write: file descriptor must be an Integer"
    end

    if (data_value = arguments.shift).is_a?(TString)
      data = data_value.value.to_slice
      LibC.write(fd, data.pointer(data.size).as(Void*), data.size)
    else
      raise "_mt_write: data for writing must be a String."
    end

    return TNil.new.as(Value)
  end

  add_kernel_method :_mt_write, 2
end
