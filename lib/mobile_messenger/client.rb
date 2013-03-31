require 'net/http'

module MobileMessenger
  class Client
    
    DEFAULTS = {
      :host => 'sendsms.mobilemessenger.com',
      :port => 443,
      :use_ssl => true,
      :ssl_verify_peer => true,
      :ssl_ca_file => File.dirname(__FILE__) + '/../../../conf/cacert.pem',
      :timeout => 30,
      :proxy_addr => nil,
      :proxy_port => nil,
      :proxy_user => nil,
      :proxy_pass => nil,
      :retry_limit => 1,
    }
    
    attr_reader :last_request, :last_response
    
    def initialize(username, password, options = {})
      @username, @password = username.strip, password.strip
      @config = DEFAULTS.merge! options
      set_up_connection
    end
    
    def post(uri, *args)
      params = args[0]; params = {} if params.empty?
      request = Net::HTTP.Post uri
      request.basic_auth @username, @password
      request.form_data = params
      connect_and_send request
    end
      
      
    private 
    
    def set_up_connection
      connection_class = Net::HTTP::Proxy @config[:proxy_addr],
        @config[:proxy_port], @config[:proxy_user], @config[:proxy_pass]
      @connection = connection_class.new @config[:host], @config[:port]
      set_up_ssl
      @connection.open_timeout = @config[:timeout]
      @connection.read_timeout = @config[:timeout]
    end
    
    def set_up_ssl
      @connection.use_ssl = @config[:use_ssl]
      if @config[:ssl_verify_peer]
        @connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
        @connection.ca_file = @config[:ssl_ca_file]
      else
        @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
    
    def connect_and_send(request)
      @last_request = request
      retries_left = @config[:retry_limit]
      begin
      rescue Exception
        raise if request.class == Net::HTTP::Post
        if retries_left > 0 then retries_left -1; retry else raise end
      end
      if response.body and !response.body.empty?
      end
    end
  end
end