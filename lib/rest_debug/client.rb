module RestDebug
  class Client
    include FromHash
    attr_accessor :base_url

    def get(sub,params={})
      url = "#{base_url}/#{sub}"
      if params.size > 0
        url += "?"
        params.each do |k,v|
          url << "#{k}=#{CGI::escape(v.to_s)}&"
        end
      end

      puts url
      raw = open(url).read
      res = JSON.parse(raw)
      puts res.inspect
      sleep(0.05)
      res
    end

    def command(cmd)
      get("command",:command => cmd)
    end

    def status
      get :status
    end

    def start(code)
      get :start, :code => code
    end
  end
end
