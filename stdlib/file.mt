deftype File
  defstatic open(name : String)
    %File{FSUtils.open(name), name}
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
end
