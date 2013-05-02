require 'spec_helper'

describe MobileMessenger::Client do
  describe "with default configuration" do
    before(:all) do
      @client = MobileMessenger::Client.new('username', 'password')
    end
    subject { @client }
    
    it 'sets up a new client instance with the given username and password' do
      @client.username.should == 'username'
      @client.instance_variable_get('@password').should == 'password'
    end
    
    it 'sets up the proper default http ssl connection' do
      connection = @client.send(:connection)
      connection.address.should == 'sendsms.mobilemessenger.com'
      connection.port.should == 443
      connection.use_ssl?.should == true
    end
    
    it 'sets up the proper http ssl connection when a different domain is given' do
      connection = @client.send(:connection, "sendsms.fakemobilemessenger.com")
      connection.address.should == 'sendsms.fakemobilemessenger.com'
      connection.port.should == 443
      connection.use_ssl?.should == true
    end
    
    describe "when sending an sms", focus: true do
      it "sends an sms with send_sms" do
        stub_post(sms_host, "/wsgw/sendSingle").to_return(body: fixture("sendSingle.txt"))
        @client.send_sms("12345", "5008885555", "Test message goes here").should include(
          "Message Id" => "1j0j9u0002bres006s43i3iu9mi0"
        )
      end
    
      it "sends a single message" do
        stub_post(sms_host, "/wsgw/sendSingle").to_return(body: fixture("sendSingle.txt"))
        @client.send(:send_single, send_single_params).should include(
          "Message Id" => "1j0j9u0002bres006s43i3iu9mi0"
        )
      end
      
      it "handles an error response", focus: true do
        #If the sendSingle() call fails, the HTTP response header contains the relevant error code. For example:
        #HTTP Status 400 - 11104- Missing value for destination
        stub_post(sms_host, "/wsgw/sendSingle").to_return(status: 400)
        lambda {
          @client.send(:send_single, send_single_params)
        }.should raise_error(MobileMessenger::RequestError)
      end
    end
    
    describe "when sending multiple messages", focus: true do
      it "sets up params for send_job" do
        stub_post(sms_host, "/wsgw/sendJob").to_return(body: fixture("sendJob.txt"))
        params = @client.send(:send_multiple_params, '12345', ['6175551000', '6175551001'], 'This is the message...')
        params.should include(
          'action'          => 'CONTENT',
          'receipt-options' => 'DELIVERED',
          'service-code'    => '12345',
          'recipient-count' => 2
        )
        params.should have_key('recipients')
      end
      
      it "#send_job_params_to_xml(params)" do
        params = @client.send(:send_multiple_params, '12345', ['6175551000', '6175551001'], 'This is the message...')
        xml = @client.send(:send_job_params_to_xml, params)        
        doc = MobileMessenger::Util::Parser.parse_xml_response(xml)
        REXML::XPath.match(doc, '/job-request/job-request-id').should_not be_empty
        REXML::XPath.match(doc, '/job-request/message/sms').first.text.should == 'This is the message...'
        REXML::XPath.match(doc, '/job-request/recipients/r').length.should == 2
        REXML::XPath.match(doc, '/job-request/recipients/r/destination').first.text.should == 'tel:6175551000'
      end
      
      it "converts send_job params to xml" do
        xml = @client.send(:send_job_params_to_xml, send_job_params)        
        xml.should == fixture("sendJobRequest.xml").read
      end
    
      it "sends a job with raw parameters" do
        stub_post(sms_host, "/wsgw/sendJob").to_return(body: fixture("sendJob.txt"))
        @client.send_job(send_job_params).should include(
          'job-request-id' => 'abc234354659234',
          'status-details' => 'Job Accepted',
        )
      end

    end
    
    it "gets the job config" do
      stub_get(ws_host, "/wsgw/getJobConfig").to_return(body: fixture("getJobConfig.txt"))
      @client.get_job_config.should include(
        'maxRecipientsPerXmlJob' => '1000',
        'serviceCodeSizeMax' => '18',
        'messageSizeMax' => '496',
      )
    end

    it "gets a job status report" do
      url = 'https://status.mobilemessenger.com/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/08urnjq00g003v0bk246419epvlk-abc234354659234.xml'
      stub_request(:get, url).to_return(body: fixture("jobStatus.xml"))
      @client.get_job_status_report(url).elements["job-request-id"].text.should == 'abc234354659234'
    end

    it "gets a job receipt report" do
      url = 'https://status.mobilemessenger.com/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/08urnjq00g003v0bk246419epvlk-abc234354659234-receipts.xml'
      stub_request(:get, url).to_return(body: fixture("jobReceipt.xml"))
      @client.get_job_status_report(url).elements["mqube-id"].text.should == '08urnjq00g003v0bk246419epvlk'
    end
  
    it "checks a mobile number" do
      stub_post(ws_host, "/wsgw/checkMobileNumber").to_return(body: fixture("checkMobileNumber.xml"))
      result = @client.check_mobile_number('5008885555')
      result['carrierId'].should == '2'
    end
    
  end
  
  describe "with custom configuration" do
    it 'sets up the requested ssl verification ca_file if provided' do
      client = MobileMessenger::Client.new('username', 'password', ssl_ca_file: '/path/to/ca/file')
      connection = client.send(:connection)
      connection.ca_file.should == '/path/to/ca/file'
    end

    it 'adjusts the open and read timeouts on the underlying Net::HTTP object when asked' do
      timeout = rand(30)
      client = MobileMessenger::Client.new('username', 'password', timeout: timeout)
      connection = client.send(:connection)
      connection.port.should == 443
      connection.use_ssl?.should == true
      connection.open_timeout.should == timeout
      connection.read_timeout.should == timeout
    end

    it 'sets up the proper http ssl connection when a proxy_host is given' do
      client = MobileMessenger::Client.new('username', 'password', sms_host: 'sendsms.fakemobilemessenger.com', proxy_addr: 'localhost')
      connection = client.send(:connection)
      connection.proxy?.should == true
      connection.proxy_address.should == 'localhost'
      connection.proxy_port.should == 80
      connection.address.should == 'sendsms.fakemobilemessenger.com'
      connection.port.should == 443
      connection.use_ssl?.should == true
    end

    it 'sets up the proper http ssl connection when a proxy_host and proxy_port are given' do
      client = MobileMessenger::Client.new('username', 'password', sms_host: 'sendsms.fakemobilemessenger.com', proxy_addr: 'localhost', proxy_port: 13128)
      connection = client.send(:connection)
      connection.proxy?.should == true
      connection.proxy_address.should == 'localhost'
      connection.proxy_port.should == 13128
      connection.address.should == 'sendsms.fakemobilemessenger.com'
      connection.port.should == 443
      connection.use_ssl?.should == true
    end
  end
end