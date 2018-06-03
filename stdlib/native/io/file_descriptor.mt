# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

deftype IO
  #doc IO.FileDescriptor
  #| An IO object representing an open file descriptor on the system.
  deftype FileDescriptor
    #doc initialize(fd) -> self
    #| Initializes a new object based on the given file descriptor, `fd`. The
    #| descriptor is assumed to have been opened before this method is called.
    def initialize(fd : Integer) : FileDscriptor; end

    #doc read(size : Integer) -> string
    #| Reads `size` bytes from the file descriptor and returns them as a new String.
    def read(size : Integer) : String; end

    #doc write(content : String) -> nil
    #| Writes the bytes of `content` to the file descriptor. The socket is not
    #| guaranteed to be flushed after this operation.
    def write(content : String) : Nil; end
  end
end
