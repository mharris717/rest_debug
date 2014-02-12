class RubyPipe
  include FromHash
  attr_accessor :code
  def end_code
    "print '<<DONE>>'"
  end
  def full_code
    "#{code}\n#{end_code}"
  end

  fattr(:tmp_filename) do
    File.expand_path(File.dirname(__FILE__) + "/../../tmp/debug_code_#{rand(1000000000)}.rb")
  end
  fattr(:pipe) do
    File.create tmp_filename,full_code
    res = IO.popen("ruby #{tmp_filename}", "r+")
    MyPipe.new(res)
  end

  ["read","closed?","open?","read_all","write","close","pid"].each do |method|
    define_method(method) { pipe.send(method) }
  end
end

class MyPipe
  attr_accessor :pipe
  def initialize(pipe)
    @pipe = pipe
  end
  fattr(:done_str) { "<<DONE>>" }

  fattr(:read_cache) { "" }
  def read
    res = pipe.read_available
    self.read_cache << res
    res.gsub(done_str,"")
  end
  def closed?
    read_cache =~ /#{done_str}/
  end
  def open?
    !closed?
  end

  def read_all
    read
    res = read_cache
    res << "\n(CLOSED)" if closed?
    res
  end

  def write(*args)
    pipe.write(*args)
  end
  def close
    read
    pipe.close
  end
  def pid
    pipe.pid
  end
end