# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc File
#| A high-level representation of a File on the system. Creating a new File
#| object will immediately open it.
#|
#| The Myst interpreter does not currently ensure that files are automatically
#| closed when the object is destroyed. As such, it is important to remember to
#| close a File object when you are done using it, or use the static versions
#| of the File methods to avoid creating new File objects in the first place.
deftype File
  #doc basename(path : String) -> string
  #| Returns the last path component of `path`, determined by splitting `path`
  #| based on the system's default path separator. This method acts like the
  #| inverse of `dirname`.
  defstatic basename(path : String); end

  #doc chmod(path : String, mode : Integer) -> nil
  #| Changes the permissions of the file specified by `path` to those
  #| represented by `mode`.
  #|
  #| Since Myst does not currently support octal literals (as mode strings are
  #| generally written), the easiest way to specify the mode is to use
  #| `String#to_i` with a `base` of 8.
  #|
  #| For example: `File.chmod(file, "644".to_i(8))`.
  defstatic chmod(path : String, mode : Integer); end

  #doc delete(path : String) -> nil
  #| Attempts to delete the file specified by `path` from the file system.
  #|
  #| This method may raise a RuntimeError if the file does not exist.
  defstatic delete(path : String); end

  #doc directory?(path : String) -> boolean
  #| Returns `true` if the file specified by `path` exists and is a directory.
  defstatic directory?(path : String); end

  #doc dirname(path : String) -> string
  #| Returns a new String of `path` with last path component removed. This
  #| method acts like the inverse of `basename`.
  defstatic dirname(path : String); end

  #doc each_line(file_name : String, &block) -> nil
  #| Opens the file specified by `file_name` and iterates the content
  #| line-by-line. Each line is passed to `block`.
  #|
  #| This method is useful for parsing large files, since the entire file
  #| does not have to be loaded into memory at one time.
  defstatic each_line(file_name : String, &block); end

  #doc empty?(path : String) -> boolean
  #| Returns `true` if the file specified by `path` exists but has no content.
  #|
  #| This method may raise a RuntimeError if the file does not exist.
  defstatic empty?(path : String); end

  #doc executable(path : String) -> boolean
  #| Returns `true` if the file specified by `path` exists and is executable
  #| by the real user of the process calling this method.
  defstatic executable?(path : String); end

  #doc exists?(path : String) -> boolean
  #| Returns `true` if the file specified by `path` exists on the filesystem.
  defstatic exists?(path : String); end

  #doc expand_path(path : String) -> string
  #| Returns a new String reprenting the expansion of `path` to an absolute
  #| path. Relative paths are referenced from the current working directory of
  #| the process calling this method.
  defstatic expand_path(path : String); end

  #doc extname(path : String) -> string
  #| Returns the extension of the file specified by `path`. The extension is
  #| considered the string after the last dot (`.`) in the `path`.
  #|
  #| If the file has no extension, this method returns a new, empty String.
  defstatic extname(path : String); end

  #doc file?(path : String) -> boolean
  #| Returns `true` if the file specified by `path` exists and is a file.
  defstatic file?(path : String); end

  #doc join(*parts) -> string
  #| Returns a new String containing all of the elements of `parts` joined
  #| together using the system's default path separator.
  defstatic join(*parts); end

  #doc lines(file_name : String) -> list
  #| Opens the file specified by `file_name` and returns a new List containing
  #| each line of the file as elements.
  #|
  #| For large files (and almost always) `File.each_line` should be preferred,
  #| as it will avoid reading the entire file into memory at one time.
  defstatic lines(file_name : String); end

  #doc link(old_path : String, new_path : String) -> nil
  #| Creates a new (hard) link at `new_path` to the existing file at `old_path`.
  defstatic link(old_path : String, new_path : String); end

  #doc read(path : String) -> string
  #| Opens the file specified by `path` and returns a single string containing
  #| the entire content of the file.
  defstatic read(path : String); end

  #doc readable?(path : String) -> boolean
  #| Returns `true` if the file specified by `path` exists and is readable by
  #| the real user of the process calling this method.
  defstatic readable?(path : String); end

  #doc real_path(path : String) -> string
  #| Returns the real path of `path` by following symlinks. The file specified
  #| by the resulting path is not guaranteed to exist (e.g., if the symlink is
  #| broken).
  defstatic real_path(path : String); end

  #doc rename(old_name : String, new_name : String) -> string
  #| Moves the file specified by `old_name` to `new_name`.
  #|
  #| This method may raise a RuntimeError if the file specified by `new_name`
  #| already exists or can not be created.
  defstatic rename(old_name : String, new_name : String); end

  #doc size(path : String) -> integer
  #| Returns the size of the file specified by `path` represented in bytes.
  defstatic size(path : String); end

  #doc basename -> string
  #| Returns the last path component of `path`, determined by splitting `path`
  #| based on the system's default path separator.
  defstatic symlink(old_path : String, new_path : String); end

  #doc symlink?(path : String) -> boolean
  #| Returns `true` if the file specified by `path` is a symbolic link.
  defstatic symlink?(path : String); end

  #doc touch(path : String) -> nil
  #| Attempts to set the access and modification times of the file specified by
  #| `path` to the current time.
  #|
  #| If the file does not exist, it will be created.
  defstatic touch(path : String); end

  #doc writable?(path : String) -> boolean
  #| Returns `true` if the file specified by `path` exists and is writable
  #| by the real user of the process calling this method.
  defstatic writable?(path : String); end

  #doc write(path : String, content : String) -> nil
  #| Writes the bytes of `content` to the file specified by `path`. `content`
  #| is assumed to already by a String value; no conversions will be performed.
  #|
  #| If the file already exists, it will be overwritten. Otherwise, a new file
  #| will be created.
  defstatic write(path : String, content : String); end



  #doc initialize(path : String, mode : String) -> file
  #| Creates a new File object for the file specified by `path` and opens it
  #| using the given opening mode. The mode can be any of the standard opening
  #| modes: `r`, `w`, `a`, or `b`.
  #|
  #| If a file is being created, its initial permissions are set using the
  #| default creation permissions for the system.
  def initialize(path : String, mode : String); end



  #doc close -> nil
  #| Flushes and closes this File object's file handle, removing it from the
  #| open file pool.
  def close; end

  #doc size -> integer
  #| Returns the size, in bytes, of this File.
  def size; end
end
