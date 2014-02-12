require 'mharris_ext'
require 'io/wait'

class IO
  def read_available
    res = ""
    while ready?
      res << read(1)
    end
    res
  end
end

class DebugManager
  include FromHash
  attr_accessor :code
  fattr(:port) { 9595 }
  
  def debug_code
    str = <<EOF
    require 'debugger'
    Debugger.wait_connection = true
    Debugger.start_remote nil, #{port}
    debugger
EOF
  end

  def full_code
    [debug_code,code].join("\n")
  end

  fattr(:server) do
    RubyPipe.new(:code => full_code).tap { |x| x.pipe }
  end

  fattr(:client) do
    res = IO.popen("/code/orig/debugger/bin/rdebug -c -p #{port} && echo 'xxDONExx'", "r+")
    MyPipe.new(res).tap { |x| x.done_str = "xxDONExx" }
  end

  def to_output
    {:client => client.read_all, :server => server.read_all}
  end

  def close
    `kill #{server.pid}`
    `kill #{client.pid}`
  end

  def do_client
    loop do
      sleep(0.5)
      res = client.read
      puts res
      return if res =~ /xxDONExx/
      puts "ENTER: "
      res = STDIN.gets
      if res.strip == "DONE"
        return
      elsif res.present?
        client.write res
      end
    end
  end
end

class RubyPipe
  include FromHash
  attr_accessor :code
  def end_code
    "print '<<DONE>>'"
  end
  def full_code
    "#{code}\n#{end_code}"
  end
  fattr(:pipe) do
    File.create "debug_code.rb",full_code
    res = IO.popen("ruby debug_code.rb", "r+")
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

def stuff
  thing.do_client

  while thing.server.open?
    print thing.server.read
    sleep(0.5)
  end
end

require 'sinatra'

def set_code(code)
  $thing.close if $thing
  $thing = DebugManager.new(:code => code)
  $thing.server
  $thing.client
  20.times do
    sleep 0.1
    if $thing.client.read_all.present?
      puts "Server: #{$thing.server.pid}"
      puts "Client: #{$thing.client.pid}"
      return
    end
  end
  raise 'no output'
end
def thing
  $thing
end

get "/" do
  @output = thing.to_output
  puts @output.inspect
  haml :index
end

get "/command" do
  command = params[:command].strip + "\n"
  thing.client.write command
end

get "/start" do
  code = params[:code].strip
  set_code code
  Time.now.to_s
end

get "/close" do
  thing.close
  "done"
end