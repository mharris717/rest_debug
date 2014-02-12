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
  
  def debug_code
    str = <<EOF
    require 'debugger'
    Debugger.wait_connection = true
    Debugger.start_remote
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
    IO.popen("/code/orig/debugger/bin/rdebug -c && echo 'xxDONExx'", "r+")
  end

  def to_output
    {:client => client.read_available, :server => server.read}
  end

  def do_client
    loop do
      sleep(0.5)
      res = client.read_available
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
  fattr(:read_cache) { "" }
  fattr(:pipe) do
    File.create "debug_code.rb",full_code
    IO.popen("ruby debug_code.rb", "r+")
  end
  def read
    res = pipe.read_available
    self.read_cache << res
    res.gsub("<<DONE>>","")
  end
  def done?
    read_cache =~ /<<DONE>>/
  end
  def open?
    !done?
  end
end

def thing
  $thing ||= begin
    code = ["puts 'hello'","puts 'goodbye'"].join("\n")
    res = DebugManager.new(:code => code)
    res.server
    res.client
    res
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
thing

get "/" do
  @output = thing.to_output
  puts @output.inspect
  haml :index
end

get "/command" do
  command = params[:command].strip + "\n"
  thing.client.write command
end


#IO.popen("/code/orig/debugger/bin/rdebug -c","r+") do |pipe|
