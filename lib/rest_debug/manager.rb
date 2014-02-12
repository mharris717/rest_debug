module RestDebug
  class Manager
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
      res = IO.popen("rdebug -c -p #{port} && echo 'xxDONExx'", "r+")
      MyPipe.new(res).tap { |x| x.done_str = "xxDONExx" }
    end

    def json_output(pipe)
      {:output => pipe.read_all, :open => pipe.open?}
    end

    def to_output
      {:client => json_output(client), :server => json_output(server)}
    end

    def close
      `kill #{server.pid}`
      `kill #{client.pid}`
    end

    def command(command)
      parts = command.to_s.split(" ")
      if parts[0] == 'break'
        file,line = *parts[1].split(":")
        if file == 'file'
          file = server.tmp_filename
          line = line.to_i + 5
          command = "break #{file}:#{line}"
          puts "new command: #{command}"
        end
      end
      client.write "#{command}\n"
    end

    class << self
      def make(code)
        res = RestDebug::Manager.new(:code => code)
        res.server
        res.client
        20.times do
          sleep 0.1
          if res.client.read_all.present?
            puts "Server: #{res.server.pid}"
            puts "Client: #{res.client.pid}"
            return res
          end
        end
        raise 'no output'
      end
    end
  end
end