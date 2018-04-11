# File extends IO.FileDescriptor, but is initialized in the native library,
# so the extension is not repeated here.
deftype File
  #doc open(path : String, mode : String) -> file
  #| Creates a new File object for the file specified by `path` and opens it
  #| using the given opening mode. The mode can be any of the standard opening
  #| modes: `r`, `w`, `a`, or `b`.
  #|
  #| If a file is being created, its initial permissions are set using the
  #| default creation permissions for the system.
  #|
  #| This should be the preferred method for creating new File objects, rather
  #| than directly instantiating new File objects.
  defstatic open(path : String, mode : String)
    %File{path, mode}
  end
  #doc open(path : String) -> file
  #| Opens the file specified by `path` in reading mode (`"r"`).
  defstatic open(path : String); open(path, "r"); end


  #doc path -> string
  #| Returns the path specified when opening this File. The path will not be
  #| expanded or modified from what was given to the initializer for this File
  #| object.
  def path; @path; end

  #doc mode -> string
  #| Returns the mode that this File was opened with; one of `"r"`, `"w"`,
  #| `"a"`, or `"b"`.
  def mode; @mode; end
end
