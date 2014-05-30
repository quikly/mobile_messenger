require 'spec_helper'

describe MobileMessenger::Client do

  it "raises an ArgumentException if username or password is not set" do
    expect {
      @client = MobileMessenger::Client.new
    }.to raise_error(ArgumentError)
  end

  describe "with default configuration" do
    before(:all) do
      @client = MobileMessenger::Client.new('username', 'password')
    end
    subject { @client }

    it 'sets up a new client instance with the given username and password' do
      expect(@client.username).to eq('username')
      expect(@client.instance_variable_get('@password')).to eq('password')
    end

    it 'sets up the proper default http ssl connection' do
      connection = @client.send(:connection)
      expect(connection.address).to eq('sendsms.mobilemessenger.com')
      expect(connection.port).to eq(443)
      expect(connection.use_ssl?).to be_true
    end

    it 'sets up the proper http ssl connection when a different domain is given' do
      connection = @client.send(:connection, "sendsms.fakemobilemessenger.com")
      expect(connection.address).to eq('sendsms.fakemobilemessenger.com')
      expect(connection.port).to eq(443)
      expect(connection.use_ssl?).to be_true
    end

    describe "when sending an sms" do
      it "sends an sms with send_sms" do
        stub_post(sms_host, "/wsgw/sendSingle").to_return(body: fixture("sendSingle.txt"))
        expect(@client.send_sms("12345", "5008885555", "Test message goes here")).to include(
          "Message Id" => "1j0j9u0002bres006s43i3iu9mi0"
        )
      end

      it "sends a single message parses ids from the status URL" do
        stub_post(sms_host, "/wsgw/sendSingle").to_return(body: fixture("sendSingle.txt"))
        expect(@client.send(:send_single, send_single_params)).to include(
          "Message Id"     => "1j0j9u0002bres006s43i3iu9mi0",
          "mqube-id"       => "0u4v16j01g20890fgq466094jjcv",
          "job-request-id" => "00q5djd01g20890fgq466094jj80"
        )
      end

      it "handles an error response" do
        #If the sendSingle() call fails, the HTTP response header contains the relevant error code. For example:
        #HTTP Status 400 - 11104- Missing value for destination
        stub_post(sms_host, "/wsgw/sendSingle").to_return(status: 400)
        expect {
          @client.send(:send_single, send_single_params)
        }.to raise_error(MobileMessenger::RequestError)
      end

      it "gets a message from an error response" do
        expect(@client.send(:error_message_from_response, double(message: '12345- This is the error message.'))).to eq "This is the error message."

      end

      it "returns a generic message from an error response" do
        expect(@client.send(:error_message_from_response, double(message: 'whatever'))).to eq "whatever"
      end

    end

    describe "when sending multiple messages" do
      it "sets up params for send_job" do
        stub_post(sms_host, "/wsgw/sendJob").to_return(body: fixture("sendJob.txt"))
        params = @client.send(:send_multiple_params, '12345', ['6175551000', '6175551001', '6175551001'], 'This is the message...')
        expect(params).to include(
          'action'          => 'CONTENT',
          'receipt-options' => 'DELIVERED',
          'service-code'    => '12345',
          'recipient-count' => 2
        )
        expect(params).to have_key('recipients')
      end

      it "#send_job_params_to_xml(params)" do
        params = @client.send(:send_multiple_params, '12345', ['6175551000', '6175551001'], 'This is the message...')
        xml = @client.send(:send_job_params_to_xml, params)
        doc = MobileMessenger::Util::Parser.parse_xml_response(xml)
        expect(REXML::XPath.match(doc, '/job-request/job-request-id')).to_not be_empty
        expect(REXML::XPath.match(doc, '/job-request/message/sms').first.text).to eq 'This is the message...'
        expect(REXML::XPath.match(doc, '/job-request/recipients/r').length).to eq 2
        expect(REXML::XPath.match(doc, '/job-request/recipients/r/destination').first.text).to eq 'tel:6175551000'
      end

      it "converts send_job params to xml" do
        xml = @client.send(:send_job_params_to_xml, send_job_params)
        expect(xml).to eq fixture("sendJobRequest.xml").read
      end

      it "sends a job with raw parameters" do
        stub_post(sms_host, "/wsgw/sendJob").to_return(body: fixture("sendJob.txt"))
        expect(@client.send_job(send_job_params)).to include(
          'job-request-id' => 'abc234354659234',
          'status-details' => 'Job Accepted',
        )
      end

    end

    it "gets the job config" do
      stub_get(ws_host, "/wsgw/getJobConfig").to_return(body: fixture("getJobConfig.txt"))
      expect(@client.get_job_config).to include(
        'maxRecipientsPerXmlJob' => '1000',
        'serviceCodeSizeMax' => '18',
        'messageSizeMax' => '496',
      )
    end

    it "gets a job status report" do
      host = "status.mobilemessenger.com"
      path = "/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/08urnjq00g003v0bk246419epvlk-abc234354659234.xml"
      stub_get(host, path).to_return(body: fixture("jobStatus.xml"))
      expect(@client.get_job_status_report("https://#{host}#{path}").elements["job-request-id"].text).to eq 'abc234354659234'
    end

    it "gets a job receipt report" do
      host = "status.mobilemessenger.com"
      path = "/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/08urnjq00g003v0bk246419epvlk-abc234354659234-receipts.xml"
      stub_get(host, path).to_return(body: fixture("jobReceipt.xml"))
      expect(@client.get_job_status_report("https://#{host}#{path}").elements["mqube-id"].text).to eq '08urnjq00g003v0bk246419epvlk'
    end

    it "checks a mobile number" do
      stub_post(ws_host, "/wsgw/checkMobileNumber").to_return(body: fixture("checkMobileNumber.xml"))
      result = @client.check_mobile_number('5008885555')
      expect(result['carrierId']).to eq 2
    end

  end

  describe "with custom configuration" do
    it 'sets up the requested ssl verification ca_file if provided' do
      client = MobileMessenger::Client.new('username', 'password', ssl_ca_file: '/path/to/ca/file')
      connection = client.send(:connection)
      expect(connection.ca_file).to eq '/path/to/ca/file'
    end

    it 'adjusts the open and read timeouts on the underlying Net::HTTP object when asked' do
      timeout = rand(30)
      client = MobileMessenger::Client.new('username', 'password', timeout: timeout)
      connection = client.send(:connection)
      expect(connection.port).to eq 443
      expect(connection.use_ssl?).to be_true
      expect(connection.open_timeout).to eq timeout
      expect(connection.read_timeout).to eq timeout
    end

    it 'sets up the proper http ssl connection when a proxy_host is given' do
      client = MobileMessenger::Client.new('username', 'password', sms_host: 'sendsms.fakemobilemessenger.com', proxy_addr: 'localhost')
      connection = client.send(:connection)
      expect(connection.proxy?).to be_true
      expect(connection.proxy_address).to eq 'localhost'
      expect(connection.proxy_port).to eq 80
      expect(connection.address).to eq 'sendsms.fakemobilemessenger.com'
      expect(connection.port).to eq 443
      expect(connection.use_ssl?).to be_true
    end

    it 'sets up the proper http ssl connection when a proxy_host and proxy_port are given' do
      client = MobileMessenger::Client.new('username', 'password', sms_host: 'sendsms.fakemobilemessenger.com', proxy_addr: 'localhost', proxy_port: 13128)
      connection = client.send(:connection)
      expect(connection.proxy?).to be_true
      expect(connection.proxy_address).to eq 'localhost'
      expect(connection.proxy_port).to eq 13128
      expect(connection.address).to eq 'sendsms.fakemobilemessenger.com'
      expect(connection.port).to eq 443
      expect(connection.use_ssl?).to be_true
    end
  end
end
