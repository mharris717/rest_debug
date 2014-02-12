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
  end
end