deftype File
  defstatic open(name : String); open(name, "r"); end
  defstatic open(name : String, mode)
    %File{FSUtils.open(name, mode), name}
  end


  def initialize(fd : Integer, name : String)
    @fd   = fd
    @name = name
  end

  def fd;   @fd;    end
  def name; @name;  end

  def close
    FSUtils.close(@fd)
  end

  def read
    FSUtils.read_all(@fd)
  end

  def read(length : Integer)
    FSUtils.read(@fd, length)
  end

  def write(data)
    FSUtils.write(@fd, data)
  end
end
