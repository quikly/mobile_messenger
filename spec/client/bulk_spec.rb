require 'spec_helper'
require 'mobile_messenger'

describe MobileMessenger::Client::Bulk do

  describe "with default configuration" do
    before(:all) do
      @client = MobileMessenger::Client.new('username', 'password')
    end
    subject { @client }

    describe "send_bulk" do
      it "send_bulk_params" do
        params = @client.send(:send_bulk_params, '12345', 'default message', {'6175551000' => 'message 1', '6175551001' => 'message 2', '6175551001' => 'message 3'})
        expect(params).to include(
          'action'          => 'CONTENT',
          'receipt-options' => 'DELIVERED',
          'service-code'    => '12345',
          'recipient-count' => 2
        )
        expect(params).to have_key('recipients')
      end

      it "#send_job_params_to_xml(params)" do
        params = @client.send(:send_bulk_params, '12345', 'default message', {'6175551000' => 'message 1', '6175551001' => 'message 2'})
        xml = @client.send(:send_job_params_to_xml, params)
        doc = MobileMessenger::Util::Parser.parse_xml_response(xml)
        expect(REXML::XPath.match(doc, '/job-request/job-request-id')).to_not be_empty
        expect(REXML::XPath.match(doc, '/job-request/message/sms').first.text).to eq('default message')
        expect(REXML::XPath.match(doc, '/job-request/recipients/r').length).to eq(2)
        expect(REXML::XPath.match(doc, '/job-request/recipients/r/destination').first.text).to eq('tel:6175551000')
        expect(REXML::XPath.match(doc, '/job-request/recipients/r/message[1]/sms').first.text).to eq('message 1')
        expect(REXML::XPath.match(doc, '/job-request/recipients/r/destination')[1].text).to eq('tel:6175551001')
        expect(REXML::XPath.match(doc, '/job-request/recipients/r/message[2]/sms').first.text).to eq('message 2')
      end
    end

    describe "check_job_status" do
      it "returns the job status" do
        stub_get(ws_host, "/wsgw/checkJobStatus").with(query: { 'JobRequestID' => 'abc234354659234'}).to_return(body: fixture("sendJob.txt"))
        expect(@client.check_job_status('abc234354659234')).to include(
          'job-request-id' => 'abc234354659234',
          'status-details' => 'Job Accepted',
        )
      end
    end
  end
end
