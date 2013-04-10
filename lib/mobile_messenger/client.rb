require 'net/http'

module MobileMessenger
  class Client
    
    DEFAULTS = {
      :sms_host => 'sendsms.mobilemessenger.com',
      :ws_host => 'ws.mobilemessenger.com',
      :port => 443,
      :use_ssl => true,
      :ssl_verify_peer => true,
      :ssl_ca_file => File.dirname(__FILE__) + '/../../../conf/cacert.pem',
      :timeout => 30,
      :proxy_addr => nil,
      :proxy_port => nil,
      :proxy_user => nil,
      :proxy_pass => nil,
      :default_product_code => nil,
      :retry_limit => 1,
    }
        
    attr_reader :username, :last_request, :last_response
    
    def initialize(username, password, options = {})
      @username, @password = username.strip, password.strip
      @config = DEFAULTS.merge(options)
    end
    
    def send_sms(from, to, message, options = {})
      defaults = {
        'action' => 'CONTENT'
      }
      
      params = defaults.merge(options).merge({
        'serviceCode' => from,
        'destination'  => to,
        'message'      => message
      })
      
      params['productCode'] = @config[:default_product_code] if params['productCode'].nil?
      
      send_single params
    end
    
    def send_multiple(from, recipients, message, options = {})
      params = send_multiple_params(from, recipients, message, options)
      send_job params
    end
    
    def send_job(params)
      host = @config[:sms_host]
      parse_send_job_response(post(host, '/wsgw/sendJob', send_job_params_to_xml(params)))
    end
    
    def check_job_status(job_id)
      host = @config[:ws_host]
      response = get(host, '/wsgw/checkJobStatus', { 'JobRequestId' => job_id })
      if response.body == 'INVALID'
        false
      else
        parse_send_job_response(response)
      end
    end
    
    def get_job_status_report(path)
      get_external_xml(path)
    end
    
    def get_job_receipt_report(path)
      get_external_xml(path)
    end
        
    def get_job_config
      host = @config[:ws_host]
      MobileMessenger::Util::Parser.parse_response(get(host, '/wsgw/getJobConfig'), "=")
    end
    
    def check_mobile_number(number, version = 2)
      host = @config[:ws_host]
      params = {
        number: number.to_i,
        version: version
      }
      MobileMessenger::Util::Parser.parse_xml_response(post(host, '/wsgw/checkMobileNumber', params))
    end
    
    private
    
    def send_single(params)
      host = @config[:sms_host]
      response = post(host, '/wsgw/sendSingle', params)
      
      parse_send_single_response(response)
    end
    
    def send_multiple_params(from, recipients, message, options = {})
      defaults = {
        'action'          => 'CONTENT',
        'receipt-options' => 'DELIVERED',
      }
      
      recipients.uniq.map! { |x| { 'destination' => "tel:#{x}"} }
      
      params = defaults.merge(options).merge({
        'service-code' => from,
        'recipient-count' => recipients.size,
        'message' => {'sms' => message},
      })
      
      if params['job-request-id'].nil?
        params['job-request-id'] = generate_job_id
      end
      
      params
    end
    
    def post(host, uri, *args)
      params = args[0]; params = {} if params.nil? || params.empty?
      request = Net::HTTP::Post.new uri
      request.basic_auth @username, @password
      request.form_data = params
      
      http = connection host
      connect_and_send request, http
    end
    
    def get(host, uri, *args)
      params = args[0]; params = {} if params.nil? || params.empty?
      unless args[1]
        uri << "?#{url_encode(params)}" if !params.empty?
      end
      request = Net::HTTP::Get.new uri
      request.basic_auth @username, @password
      
      http = connection host
      connect_and_send request, http
    end  
    
    def get_external_xml(path)
      uri = URI(path)
      http = connection uri.host, uri.port
      request = Net::HTTP::Get.new(uri)
      response = connect_and_send request, http
      MobileMessenger::Util::Parser.parse_xml_response(response)
    end
    
    def connection(host = nil, port = nil)
      host ||= @config[:sms_host]
      port ||= @config[:port]
      connection = Net::HTTP.new host, port,
        @config[:proxy_addr], @config[:proxy_port], @config[:proxy_user], @config[:proxy_pass]
      set_up_ssl(connection)
      connection.open_timeout = @config[:timeout]
      connection.read_timeout = @config[:timeout]
      connection
    end
    
    def set_up_ssl(connection)
      connection.use_ssl = @config[:use_ssl]
      if @config[:ssl_verify_peer]
        connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
        connection.ca_file = @config[:ssl_ca_file]
      else
        connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
    
    def connect_and_send(request, connection)
      @last_request = request
      retries_left = @config[:retry_limit]
      begin
        response = connection.request request
        @last_response = response
        if response.kind_of? Net::HTTPServerError
          raise MobileMessenger::ServerError
        end
      rescue Exception
        raise if request.class == Net::HTTP::Post
        if retries_left > 0 then retries_left -1; retry else raise end
      end
      if response.body and !response.body.empty?
        object = response.body
      end
      if response.kind_of? Net::HTTPClientError
        raise MobileMessenger::RequestError
      end
      object
    end
    
    def parse_send_job_response(response)
      MobileMessenger::Util::Parser.parse_response(response, "=")
    end
    
    def parse_send_single_response(response)
      MobileMessenger::Util::Parser.parse_response(response, ": ")
    end
    
    def send_job_params_to_xml(params)
      {
        'JobXML' => '<job-request>' + MobileMessenger::Util::Parser.to_xml(params) + '</job-request>'
      }
    end
  
    def generate_job_id
      SecureRandom.uuid
    end
  end
end