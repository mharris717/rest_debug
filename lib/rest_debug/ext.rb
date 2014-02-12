class IO
  def read_available
    res = ""
    while ready?
      res << read(1)
    end
    res
  end
end