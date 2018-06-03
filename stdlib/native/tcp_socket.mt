# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc TCPSocket
#| A Transmission Control Protocol (TCP/IP) socket.
#|
#| This type inherits from `IO`.
deftype TCPSocket
  #doc initialize(host, port) -> self
  #| Initializes a new socket to reference the TCP server specified at `host`
  #| on the given `port`.
  def initialize(host : String, port : Integer) : TCPSocket; end

  #doc read(size : Integer) -> string
  #| Reads `size` bytes from the socket and returns them as a new String.
  def read(size : Integer) : String; end

  #doc write(content : String) -> nil
  #| Writes the bytes of `content` to the socket. The socket is not guaranteed
  #| to be flushed after this operation.
  def write(content : String) : Nil; end
end
