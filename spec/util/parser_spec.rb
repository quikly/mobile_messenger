require 'spec_helper'

describe MobileMessenger::Util::Parser do
  it 'parses a simple response with equal sign separators' do
    response = fixture('sendJob.txt')
    #stub_get("/1.1/account/verify_credentials.json").to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    result = MobileMessenger::Util::Parser.parse_response(response.read, '=')
    expect(result).to include(
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
    expect(result).to include(
      "Message Id" => "1j0j9u0002bres006s43i3iu9mi0",
      "StatusURL"  => "https://status.mobilemessenger.com/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/0u4v16j01g20890fgq466094jjcv-00q5djd01g20890fgq466094jj80.xml",
      "ReceiptURL" => "https://status.mobilemessenger.com/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/0u4v16j01g20890fgq466094jjcv-00q5djd01g20890fgq466094jj80-receipts.xml"
    )
  end

  it 'parses an xml response' do
    response = fixture('jobStatus.xml')
    result = MobileMessenger::Util::Parser.parse_xml_response(response.read)
  end

  it 'creates simple xml from a hash' do
    xml = MobileMessenger::Util::Parser.to_xml({
      'this-is' => 'my-value'
    })
    expect(xml).to eq('<this-is>my-value</this-is>')
  end

  it 'does not complain if the attribute is nil' do
    xml = MobileMessenger::Util::Parser.to_xml({
      'nil-value' => nil
    })
    expect(xml).to eq('<nil-value></nil-value>')
  end

  it 'creates simple xml from a nested hash' do
    xml = MobileMessenger::Util::Parser.to_xml({
      'message' => {
        'sms' => 'Two guys go into a bar...',
      },
      'action' => 'CONTENT',
      'recipients' => [
        { 'r' => {'destination' => 'tel:6175551000'}},
        { 'r' => {'destination' => 'tel:6175551001'}},
      ]
    })
    expect(xml).to eq('<message><sms>Two guys go into a bar...</sms></message><action>CONTENT</action><recipients><r><destination>tel:6175551000</destination></r><r><destination>tel:6175551001</destination></r></recipients>')
  end

  it 'escapes xml text' do
    xml = MobileMessenger::Util::Parser.to_xml({
      'math-is-fun' => 'we know that 2 > 1 && 1 > 0'
    })
    expect(xml).to eq('<math-is-fun>we know that 2 &gt; 1 &amp;&amp; 1 &gt; 0</math-is-fun>')
  end

  context "parsing status url" do
    it 'parses a job-status-id and mqube-id from a status url' do
      url = 'https://status.mobilemessenger.com/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/0u4v16j01g20890fgq466094jjcv00q5djd01g-20890f-gq466094jj80.xml'
      expect( MobileMessenger::Util::Parser.job_and_mqube_id_from_status_url(url)).to eq({'job-request-id' => '20890f-gq466094jj80', 'mqube-id' => '0u4v16j01g20890fgq466094jjcv00q5djd01g'})
    end

    it 'does not break when format is unexpected' do
      url = 'https://status.mobilemessenger.com/status/gws/7fdhts45y434908ksl78m21d8641/SMS/2007052218/whatever.xml'
      expect( MobileMessenger::Util::Parser.job_and_mqube_id_from_status_url(url)).to eq(nil)
    end
  end

end
