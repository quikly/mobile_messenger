require 'spec_helper'

describe MobileMessenger::Util do
  it 'takes a hash and returns a url-encoded string' do
    MobileMessenger::Util::url_encode(send_single_params).should == "destination=5008885555&serviceCode=12345&message=A+giraffe+goes+into+a+bar&productCode=ACMEX_12345_JOKE_199_S&notificationURL=http%3A%2F%2Fmysite.com%2Fsms%2FjobComplete.jsp&receiptOption=DELIVERED"
  end
end
