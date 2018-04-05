# File extends IO.FileDescriptor, but is initialized in the native library,
# so the extension is not repeated here.
deftype File
  defstatic open(name : String, mode)
    %File{name, mode}
  end
  defstatic open(name : String); open(name, "r"); end

  def path; @path; end
  def mode; @mode; end
end
