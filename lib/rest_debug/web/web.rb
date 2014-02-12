require 'sinatra'
load File.dirname(__FILE__) + "/../../rest_debug.rb"

def set_code(code)
  $manager.close if $manager
  $manager = RestDebug::Manager.new(:code => code)
  $manager.server
  $manager.client
  20.times do
    sleep 0.1
    if $manager.client.read_all.present?
      puts "Server: #{$manager.server.pid}"
      puts "Client: #{$manager.client.pid}"
      return
    end
  end
  raise 'no output'
end
def manager
  $manager
end

get "/status" do
  @output = manager.to_output
  @output.to_json
end

get "/command" do
  command = params[:command].strip + "\n"
  manager.client.write command
  10.times { sleep(0.05) }
  {:output => manager.client.read}.to_json
end

get "/start" do
  code = params[:code].strip
  set_code code
  {:started => Time.now.to_s}.to_json
end

get "/close" do
  manager.close
  "done"
end