require "socket"

module Myst
  class Interpreter
    NativeLib.method :tcp_socket_init, TInstance, host : String, port : Int64 do
      socket = TCPSocket.new(host, port)
      @fd_pool[socket.fd] = socket

      this.ivars["@fd"] = socket.fd.to_i64
      this.ivars["@host"] = host
      this.ivars["@port"] = port
      this
    end

    NativeLib.method :tcp_socket_read, TInstance, size : Int64 do
      fd_id = this.ivars["@fd"].as(Int64).to_i32
      fd = @fd_pool[fd_id]

      slice = Slice(UInt8).new(size)
      fd.read(slice)
      String.new(slice)
    end

    NativeLib.method :tcp_socket_write, TInstance, content : String do
      fd_id = this.ivars["@fd"].as(Int64).to_i32
      fd = @fd_pool[fd_id]

      fd.write(content.to_slice)
      TNil.new
    end

    def init_tcp_socket(kernel : TModule, io_type)
      tcp_socket_type = TType.new("TCPSocket", kernel.scope, io_type)
      tcp_socket_type.instance_scope["type"] = tcp_socket_type

      NativeLib.def_instance_method(tcp_socket_type, :initialize, :tcp_socket_init)
      NativeLib.def_instance_method(tcp_socket_type, :read,       :tcp_socket_read)
      NativeLib.def_instance_method(tcp_socket_type, :write,      :tcp_socket_write)

      tcp_socket_type
    end
  end
end
