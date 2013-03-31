require 'spec_helper'

describe MobileMessenger::Util::Parser do
  it 'parses a simple response with equal sign separators' do
    response = fixture('sendJob.txt')
    #stub_get("/1.1/account/verify_credentials.json").to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    result = MobileMessenger::Util::Parser.parse_response(response.read, '=')
    result.should include(
      "job-request-id"            => "abc234354659234",
      "mqube-id"                  => "08urnjq00g003v0bk246419epvlk",
      "accepted-date"             => "05/22/2007 6:15:35 PM UTC",
      "status-code"               => "0",
      "status-details"            => "Job Accepted",
      "max-retries"               => "0",
      "retry-delay-secs"          => "0",
      "num-destinations-accepted" => "3",
      "status-url"                => "https://status.mobilemessenger.com/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/08urnjq00g003v0bk246419epvlk-abc234354659234.xml", 
      "receipt-url"               => "https://status.mobilemessenger.com/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/08urnjq00g003v0bk246419epvlk-abc234354659234-receipts.xml"      
    )
  end
  
  it 'parses a simple response with colon separators' do
    response = fixture('sendSingle.txt')
    result = MobileMessenger::Util::Parser.parse_response(response.read, ': ')
    result.should include(
      "Message Id" => "1j0j9u0002bres006s43i3iu9mi0",
      "StatusURL"  => "https://status.mobilemessenger.com/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/0u4v16j01g20890fgq466094jjcv-00q5djd01g20890fgq466094jj80.xml", 
      "ReceiptURL" => "https://status.mobilemessenger.com/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/0u4v16j01g20890fgq466094jjcv-00q5djd01g20890fgq466094jj80-receipts.xml"      
    )
  end
  
  
  
end